require 'HTTParty'

class CheckOnlineStatus

  def initialize(roles, resource)
    @roles = roles
    @resource = resource
  end

  def check
    pending = true
    while pending
      pending = false
      @roles.each do |role, servers|
        servers_to_check = servers.select { |s| ! s.ok_to_terminate }
        unless servers_to_check.empty?
          check_servers(servers_to_check)
          pending = true
        end
      end
      sleep 15
    end
  end

  private

  def check_servers(servers_to_check)
    servers_to_check.each do |server|
      puts "Checking Server #{server.ip}"
      begin
        response = HTTParty.get("http://#{server.ip}#{@resource}")
        if response =~ /Welcome to Think Through Math/
          server.ok_to_terminate = true
          puts "Ready to terminate #{server.ip}"
        end
      rescue
        server.ok_to_terminate = false
      end
    end
  end

end