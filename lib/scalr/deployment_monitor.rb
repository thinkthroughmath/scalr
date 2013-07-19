# monitor a deployment for a particular role
require 'scalr/server_deployment'
require 'scalr/log_sink'

module Scalr
  class DeploymentMonitor

    attr_accessor :error, :role, :status

    def initialize(role, farm_id, verbose = false)
      @farm_id   = farm_id
      @role      = role
      @servers = @role.servers_running.map {|server| Scalr::ServerDeployment.new(@farm_id, role, server)}
      @status    = 'NOT EXECUTED'
      @verbose   = verbose
    end

    def start(deployment_caller)
      response = deployment_caller.invoke(farm_role_id: @role.id)
      if response.nil? || response.failed?
        @status = 'FAILED'
        @error = response.nil? ? 'Input validation error' : response.error
        return
      end
      @status = 'STARTED'
      assign_tasks(response.content)
      show_servers if @verbose
    end

    def poll
      unless done?
        accumulate_logs
        if refresh_status
          puts "  #{name}: #{status} - #{servers_status.join(' ')}" if @verbose
        end
      end
    end

    def completed?; @status == 'completed' end
    def deployed?;  @status == 'deployed'  end
    def deploying?; @status == 'deploying' end
    def done?;      @servers.all? &:done?  end # this monitor is done whenever all of its servers are done
    def failed?;    @status == 'failed'    end
    def pending?;   @status == 'pending'   end

    def full_status
      failed? ? "#{status}: #{error}" : status
    end

    def name
      @role.name
    end

    # status will change to one of DEPLOYED|DEPLOYING|FAILED|PENDING
    # iff all the tasks have the same status
    # returns: true if any server status changed, false if none did
    def refresh_status
      changed = @servers.any? &:refresh
      @status = 'completed' if @servers.all? {|server_deploy| server_deploy.completed?}
      @status = 'deployed'  if @servers.all? {|server_deploy| server_deploy.deployed?}
      @status = 'deploying' if @servers.all? {|server_deploy| server_deploy.deploying?}
      @status = 'failed'    if @servers.all? {|server_deploy| server_deploy.failed?}
      @status = 'pending'   if @servers.all? {|server_deploy| server_deploy.pending?}
      changed
    end

    def servers_not_done
      @servers.find_all {|server_deploy| !server_deploy.done?}
    end

    def servers_status
      @servers.map &:to_s
    end

    def show_servers
      puts "ROLE: #{@role.name}"
      puts servers_status.join("\n")
    end

    def summaries
      @servers.map do |server_deploy|
        server_failures = server_deploy.failures
        if server_failures.empty?
          server_status = server_deploy.done? ? 'OK' : server_deploy.status.upcase
          "#{server_status}: #{server_deploy.name}"
        else
          "FAIL: #{server_deploy.name}\n" +
              server_failures.map {|failure|
                "** Script: #{failure.script_name}; Exit: #{failure.exit_code}; Exec time: #{failure.exec_time} sec\n" +
                failure.types.map{|failure_type| failure_type.name + "\n" + failure_type.description}.join("\n")
              }.join("\n")
        end
      end
    end

    def summarize_server_status
      @servers.
          group_by {|s| s.status}.
          map {|status, server_deploys| "#{status}: #{server_deploys.length}"}
    end

    def to_s
      "Role #{role.name} - #{full_status}"
    end

  private

    def accumulate_logs
      @servers.each {|server_deploy| server_deploy.scan_logs}
    end

    def assign_tasks(tasks)
      tasks.each do |task|
        server_deploy = deployment_for_server(task.server_id)
        unless server_deploy
          puts "WEIRD! Scalr generated a task for which we didn't have a server entry! Task: #{task.to_s}"
          server_deploy = Scalr::ServerDeployment.new(@farm_id, @role, @role.find_server(task.server_id))
          @servers << server_deploy
        end
        server_deploy.assign_task(task)
      end
      @servers.find_all {|server_deploy| server_deploy.missing_task?}.each do |server_deploy|
        puts "WEIRD! No Scalr task for running server: #{server_deploy.id}"
        @servers.delete(server_deploy)
      end
    end

    def deployment_for_server(server_id)
      @servers.find {|server| server_id == server.id}
    end

    def log_sinks
      @log_sinks ||= Scalr::LogSinks.new(@servers.map &:log_sink)
    end

    def poller
      @poller ||= Scalr::StatefulScriptPoller.new(@farm_id, @role.servers_running, 'TTMAppConfigAndLaunch')
    end
  end
end