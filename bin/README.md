# ttmscalr - Manage Imagine Math infrastructure through this Scalr-based command-line tool

## Installing + Configuring

* Clone `git@github.com:thinkthroughmath/scalr.git`
* Add the `scalr/bin` directory to your `PATH` environment variable (see: [Add to Path](#add-to-path))
* Install dependencies:
  * `gem install main`
  * `activesupport` and `ruby-hmac` are also required. However, if running from
  inside an Apangea gem environment, you'll likely already have these.
  Note: If you use rvm gemsets, you'll need to install these gems in the
  gemsets in which you'd like to use ttmscalr.
* Build and install the scalr gem:
  * `gem build scalr.gemspec`
  * `gem install ./scalr-0.2.28.gem`
* Get and configure API credentials (see: [Scalr API Credentials](#scalr-api-credentials))
* Now you should be able to run `ttmscalr farm:list`

### Add to PATH

Add this directory to your PATH. For a one-off, assuming this repo is
`~/Projects/TTM/scalr` you'd do:

    $ export PATH=~/Projects/TTM/scalr/bin:$PATH

For a more permanent solution you might have in your `~/.bashrc` or
`~/.bash_profile` something like:


    SCALR_HOME=~/Projects/TTM/scalr
    NODE_HOME=~/tools/node/current
    ...

    export PATH=~/bin:$SCALR_HOME/bin:$NODE_HOME/bin:$PATH

### Scalr API Credentials

You need to tell Scalr your API credentials in order to use this tool effectively.
Don't have these? An Imagine Math Scalr administrator can create an account for you.

Follow these steps to obtain and set your keys:
  1. Log in to: https://my.scalr.com
  1. Click on your profile in the upper-right corner of the page
  1. Choose 'API Access'
  1. Click the link of the message "Click here if you're looking
for first generation API access credentials."
  1. Click in checkbox "Enable API access for
«your_email»"
  1. Copy API Key ID and API Access Key.

You can tell Scalr your credentials in one of two ways:

__1.__ Export data to your environment. Both of the following must be
defined:

* `SCALR_KEY_ID`
* `SCALR_ACCESS_KEY`

__2.__ Create one of the following files with access credentials:

* `access_info` in the directory where the Scalr gem is stored
* `~/.ttm_scalr_access_info` __<<< preferred!__
* `access_info` in the current directory

(More specific files will be preferred over least specific.)

The Scalr access credentials should be in the file like this:

    KEY_ID     = 46ab...
    ACCESS_KEY = nxm+4hN...

DO NOT ADD THIS FILE TO git! It's already in `.gitignore` so you
shouldn't be able to do so accidentally in the scalr gem.

### Test it out!

To see if it's working run:

    $ ttmscalr farm:list

If you want to see the URL and response content:

    $ ttmscalr farm:list --debug

## Quick intro

Once you've installed, you can test it out by listing some resources:

    $ ttmscalr farm:list
    You do not currently have a file for scalr aliases.
    Creating one for you now in /home/cwinters/.ttm_scalr_aliases.json...
    DONE - file written. Let's go!
    14498 - Production           - RUNNING - aliases: production, ttm-production
    15275 - Review               - RUNNING - aliases: review, ttm-review, ttm-staging
    15356 - Production-DB-Master - RUNNING - aliases: prod-db-primary, master
    15357 - Production-DB-Shard1 - RUNNING - aliases: prod-db-shard1, shard1
    15358 - Production-DB-Shard2 - RUNNING - aliases: prod-db-shard2, shard2
    15359 - Production-DB-Shard3 - RUNNING - aliases: prod-db-shard3, shard3
    15360 - Production-DB-Shard4 - RUNNING - aliases: prod-db-shard4, shard4
    15548 - DW-Production        - TERMINATED - aliases: N/A

Note: The message about missing aliases always happens with the first command you run.
See more about them below.

You can get details about a farm:

    $ ttmscalr farm review
    FARM: 15275 (aliases: review, ttm-review, ttm-staging)
    ========================================
    ROLE: RailsAppServer (our aliases: web, rails)
      Farm role ID:  53302
      Scaling:       YES [Range: 1-1]
      Platform:      Instance: m1.large; Availability: us-east-1a
      Servers:
           web.1 - Running - Uptime 81.92 - Instance: m1.large; Availability: us-east-1a

    ROLE: Sidekiq (our aliases: sidekiq)
      Farm role ID:  53303
      Scaling:       YES [Range: 1-1]
      Platform:      Instance: m1.large; Availability: us-east-1a
      Servers:
           sidekiq.1 - Running - Uptime 77.27 - Instance: m1.large; Availability: us-east-1a

    ROLE: Bunchball (our aliases: bunchball, bb)
      Farm role ID:  53304
      Scaling:       YES [Range: 1-1]
      Platform:      Instance: m1.large; Availability: us-east-1a
      Servers:
           bunchball.1 - Running - Uptime 89.3 - Instance: m1.large; Availability: us-east-1a

    ROLE: Reports (our aliases: reports)
      Farm role ID:  53305
      Scaling:       YES [Range: 1-1]
      Platform:      Instance: m1.large; Availability: us-east-1a
      Servers:
           reports.1 - Running - Uptime 83.07 - Instance: m1.large; Availability: us-east-1a

    ROLE: DevDebug (our aliases: debug)
      Farm role ID:  53306
      Scaling:       YES [Range: 1-1]
      Platform:      Instance: m1.large; Availability: us-east-1a
      Servers:
           debug.1 - Running - Uptime 2666.4 - Instance: m1.large; Availability: us-east-1a

    ROLE: SystemWatcher (our aliases: watcher)
      Farm role ID:  53307
      Scaling:       YES [Range: 1-1]
      Platform:      Instance: m1.large; Availability: us-east-1a
      Servers:
           watcher.1 - Running - Uptime 83.02 - Instance: m1.large; Availability: us-east-1a

    ROLE: PGSQL-9-2 (our aliases: N/A)
      Farm role ID:  53308
      Scaling:       YES [Range: 2-2]
      Platform:      Instance: m3.2xlarge; Availability: us-east-1a
      Servers:
           #1 - Running      - Uptime 80.42 - Instance: m3.2xlarge; Availability: us-east-1a
           #2 - Terminated   - Uptime 26.18 - Instance: m3.2xlarge; Availability: us-east-1a
           #2 - Terminated   - Uptime 40.03 - Instance: m3.2xlarge; Availability: us-east-1a
           #2 - Initializing - Uptime  6.17 - Instance: m3.2xlarge; Availability: us-east-1a

To access one of the servers, you can SSH directly in. You cannot access a server until
you've downloaded and setup the farm's private key. Steps are provided the first time you
try to connect to a farm.

For example:

    $ ttmscalr ssh debug.1 -f review

    Expected key file (/home/cwinters/.ssh/FARM-15275.us-east-1.private.pem) does not exist.
    Here's how to fix it:
      - go to https://my.scalr.com/#/sshkeys/view
      - find the row with the 'Farm ID' column as 15275
      - click the 'Actions' dropdown in its far right column
      - choose 'Download private key'
      - store it to /home/cwinters/.ssh/FARM-15275.us-east-1.private.pem
      - execute: 'chmod 400 /home/cwinters/.ssh/FARM-15275.us-east-1.private.pem'
        (so ssh won't complain about permissive permissions)

## Common tasks

### Run a rake task

Most farms have a `debug` role for this purpose. It has the same code
as the others but doesn't run any active services. To run a rake
task on the 'review' farm, do:

    $ ttmscalr ssh debug.1 -f review
    # cd /var/www
    # bundle exec rake mytask

## Scalr commands: overview

### Getting help

You can ask for help on any command:

    $ ttmscalr command --help

For example:

    $ ttmscalr ssh --help
    NAME
      ttmscalr

    SYNOPSIS
      ttmscalr ssh server [options]+

    DESCRIPTION
      Generate SSH command to connect to a specific server within a farm and role.

    PARAMETERS
      server (1 -> server)
          Server index to use with role, or "role.index" name (e.g., "rails.2")
      --farm=farm, -f (0 ~> farm)
          Farm containing role + server
      --role=[role], -r (0 ~> role)
          Role with server, required unless using role name with "server" arg
      --help, -h

    EXAMPLES
      ttmscalr ssh rails.1 -f review
      ttmscalr ssh sidekiq.2 -f production
      ttmscalr ssh 12 -f production -r rails

The parameter description tells you whether it's required or optional.

### Aliasing Scalr resources

Many parameters are identified by numeric ID in Scalr. But that's
not friendly to us humans, so we alias them for you. You can control these
aliases (the first time you run a command with ttmscalr we'll generate a JSON
file with default aliases), by making changes to the alias file.

For example, to add 'Zoidberg' as an alias for the 'Review' farm, change this line:

    "15275": [ "Review", "ttm-review", "ttm-staging" ],

to this:

    "15275": [ "Review", "ttm-review", "ttm-staging", "Zoidberg" ],

We add new aliases. To include them you can either:

* delete the file (`~/.ttm_scalr_aliases.json`) and the next time you
  run the script it'll regenerate the alias file for you, or
* if you've customized the aliases you may want to modify them
  yourself -- see `Scalr::TTMAliasReader` in `lib/scalr/ttm.rb` for
  what we would generate

## Scalr commands: list

### Command: deploy

Deploys a Scalr application to all non-database roles on a farm.

Note: We typically will use https://github.com/thinkthroughmath/mathbot for most standard deploys.

### Command: config:get

Retrieve configuration for a farm. If you pass in a key you'll get just
that value back so you can use it in a shell.

### Command: config:set

Assign configuration as key/value pairs to a farm. You can do multiple at
once, or you can read from a file.

Note: Environment variable changes require a farm restart. A deploy will
perform a necessary restart or we can implement a rolling restart (where all
servers in a farm are restarted one at a time, to ensure that the application
is always "up").

### Command: maintenance

Turn maintenance mode on or off.

### Command: launch

Launch a server within a farm. Unfortunately you can only do one at a time.
(You can also launch a farm with this, but you'll almost never have to do this.)

### Command: terminate

Kill a server; if scalr thinks it should spin another up to compensate it will.

### Command: psql

Generate a psql command that will connect you to one of the databases.

Note: You may need to "tunnel" this command if you are not launching the command
from a "trusted" (Scalr administrator approved) network.

### Command: ssh

Generate a ssh command that will connect you to a specific server.

### Command: application:list

List available applications

### Command: farm

### Command: farm:list

### Command: farm:server

### Command: script:list

## Scalr background

There are some fundamental differences between Scalr and
Heroku. Heroku has a simple, flat model of
dyno-per-Procfile-entry. Scalr has multiple abstraction layers to let
you copy your app, restart parts of it without others being touched,
and so on.

The layers are:

* Farm
* Role
* Server

A __farm__ may contain multiple __roles__, each of which corresponds
roughly to a Procfile entry. Each __role__ within a __farm__ has its
own scaling algorithm (grow by n or %, min/max, etc). Each __role__
has a number of __servers__ which actually run the code.

There's one difference with Heroku related to the database
servers. Each functional database (master, shard 1, etc.) is deployed
to its own __farm__ as a result of how Scalr's Postgres support
works. But all TTM __roles__ have access to all the databases through
configuration.

Some examples of our __farms__ and __roles__:

Farms:

* Prod-AppServer
* Prod-DB-(Primary|Shard([1-4]))
* Review

Roles:

* RailsAppServer
* Sidekiq
* Bunchball
* Reports
* DevDebug
* SystemWatcher

Configuration can be defined at the __Global__, __Farm__, __Role__, or
__Server__ levels and due to some scripting from our end are available
as environment variables similar to Heroku. Though unlike Heroku they
must begin with the `TTM_` prefix to be propagated.

## Parking lot + ideas

### Usability

* Be able to use farm name vs ID
* Be able to use 'internal mapping' of farm name vs scalr (e.g.,
  'ttm-production' vs 'Prod-AppServer', 'ttm-staging' or 'ttm-review'
  vs 'Review', etc.)

### config

Tasks to implement:

* get: globals || farm || farm + role || farm + role + server, all or
  single name
* set: globals || farm || farm + role || farm + role + server, one or
  more key/value pairs

### deploy

Tasks to accomplish:

* git push to scalr source
* scalr API deploy
* ...ensure asset compilation works, if not fail the deploy!
* ...triggers graceful unicorn restart
* ...unicorn will issue error if new code fails (??)
* listen for errors on PaperTrail

### ps

Tasks to implement:

* restart: takes farm || farm + role || farm + role + server
* start: takes farm || farm + role || farm + role + server
* stop: takes farm || farm + role || farm + role + server
* info: list/restrict-to farms || farms + roles || farms + roles +
  servers; give deterministic + short (!!) IDs to servers so users
  don't need to juggle GUIDs -- see scalar 'index' of each server.

### load_test

Tasks to accomplish:

* scalr API run rake task on environment (loads testing data; make
  available in app? pushes to S3?)
* get CSV of data that was loaded (HTTP call? pull file to S3?)
* scalr API start a specific farm
* wait for farm to start
* ... run load test ...
* stop specific farm (unload data?)

### psql

### ssh

## Also: api_check

You can check the Scalr API configuration with:

    ruby bin/api_check.rb

Which if everything is ok will just output:

    EVERYTHING OK!!!!!

You can also view all the API commands:

    ruby bin/api_check.rb all

or just those matching a substring:

    $ ruby bin/api_check.rb match app
    dm_application_create (DmApplicationCreate) @ 2.3.0
      => name (Name) [Required? true]
      => source_id (SourceID) [Required? true]

    dm_application_deploy (DmApplicationDeploy) @ 2.3.0
      => application_id (ApplicationID) [Required? true]
      => farm_role_id (FarmRoleID) [Required? true]
      => remote_path (RemotePath) [Required? true => default: /var/www]

    dm_applications_list (DmApplicationsList) @ 2.3.0

# Scalr API ideas

* Tasks should have a timestamp (`dm_deployment_tasks_list`)
* I should be able to fetch logs not only by a pagination offset,
  but also before/after/between timestamps
* Would be very interesting to have webhooks for feedback from
  scripting/system logs => I register a URL for a particular script
  (or maybe for all scripts?) and scalr posts status updates to the
  URL as they come up
