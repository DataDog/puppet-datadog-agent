Puppet & Datadog
================

Description
-----------

A module to:

1. install the [DataDog](http://www.datadoghq.com)  agent
2. to send reports of puppet runs to the Datadog service [Datadog](http://www.datadoghq.com/).

Requirements
------------

* [puppet](http://puppetlabs.com)
* A [Datadog](http://www.datadoghq.com) account and an API Key

On your Puppet master:

* [dogapi](https://rubygems.org/gems/dogapi) gem (v 1.0.3 and later)

Installation
------------

Install `datadog_agent` as a module in your Puppet master's module path.

    puppet module install datadog-datadog_agent

Usage
-----

Once the `datadog_agent` module is installed on your master, there's a tiny bit of configuration
that needs to be done.

1. Update the default class parameters with your [API key](https://app.datadoghq.com/account/settings#api)
   (and confirm the DataDog URL is correct in datadog::params).

2. Specify the module on any nodes you wish to install the DataDog
   Agent.

        include datadog_agent

  Or assign this module using the Puppet 2.6 style Parameterized class:
        class { 'datadog_agent':
          api_key => "yourkey",
        }

  On your Puppet master, enable reporting:

        class { 'datadog_agent':
          api_key            => "yourkey",
          puppet_run_reports => true,
        }

Reporting
---------
To enable reporting of changes to the Datadog timeline, enable the report 
processor on your Puppet master, and enable reporting for your clients. 
The clients will send a run report after each check-in back to the master, 
and the master will process the reports and send them to the Datadog API.


In your Puppet master `/etc/puppet/puppet.conf`, add these configuration options:

    [main]
    # No need to modify this section
    # ...
        
    [master]
    # Enable reporting to datadog
    reports=datadog_reports
    # If you use other reports already, just add datadog_reports at the end
    # reports=store,log,datadog_reports
    # ...
    
    [agent]
    # ...
    pluginsync=true
    report=true
    
And on all of your Puppet client nodes add:

    [agent]
    # ...
    report=true
    
If you get

    err: Could not send report:
    Error 400 on SERVER: Could not autoload datadog_reports:
    Class Datadog_reports is already defined in Puppet::Reports
    
Make sure `reports=datadog_reports` is defined in **[master]**, not **[main]**.

Step-by-step
============

This is the minimal set of files to use to get started. These files assume puppet 2.7.x

/etc/puppet/puppet.conf
-----------------------

    [main]
    logdir=/var/log/puppet
    vardir=/var/lib/puppet
    ssldir=/var/lib/puppet/ssl
    rundir=/var/run/puppet
    factpath=$vardir/lib/facter
    templatedir=$confdir/templates
    
    [master]
    # These are needed when the puppetmaster is run by passenger
    # and can safely be removed if webrick is used.
    ssl_client_header = SSL_CLIENT_S_DN 
    ssl_client_verify_header = SSL_CLIENT_VERIFY
    report = true
    reports = datadog_reports
    pluginsync = true
    syslogfacility = user
    
    [agent]
    report = true
    pluginsync = true

/etc/puppet/manifests/nodes.pp
------------------------------

    node "default" {
        class { "datadog":
            api_key => "INSERT YOU API KEY HERE",
        }
    }
    node "puppetmaster" {
        class { "datadog":
            api_key            => "INSERT YOUR API KEY HERE",
            puppet_run_reports => true
        }
    }

/etc/puppet/manifests/site.pp
-----------------------------

    import "nodes.pp"

Run Puppet Agent
----------------

    sudo /etc/init.d/puppetmaster restart
    sudo puppet agent --onetime --no-daemonize --no-splay --verbose
    
You should see something like:

    info: Retrieving plugin
    info: Caching catalog for alq-linux.dev.datadoghq.com
    info: Applying configuration version '1333470114'
    notice: Finished catalog run in 0.81 seconds

Verify on Datadog
-----------------

Go to [the Setup page](https://app.datadoghq.com/account/settings#integrations) and you should see this

![Puppet integration][puppet-integration]

[puppet-integration]: https://img.skitch.com/20120419-hdd7e9fuxhgeei8y5yr7hyt8e.png

Search for "Puppet" in the Stream and you should see something like this:

![Puppet Events in Datadog][puppet-events]

[puppet-events]: https://img.skitch.com/20120403-bdipicbpquwccwxm2u3cwdc6ar.png

Miscellaneous
=============

Authors
-------

* James Turnbull <james@lovedthanlost.net>
* Alexis Lê-Quôc <alq@datadoghq.com>
* Rob Terhaar <rob@atlanticdynamic.com>

License
-------

    Author:: James Turnbull (<james@lovedthanlost.net>)
    Copyright:: Copyright (c) 2011 James Turnbull
    License:: Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
