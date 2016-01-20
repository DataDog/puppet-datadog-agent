Puppet & Datadog
================

[![Build Status](https://travis-ci.org/DataDog/puppet-datadog-agent.svg?branch=master)](https://travis-ci.org/DataDog/puppet-datadog-agent)

Description
-----------

A module to:

1. install the [DataDog](http://www.datadoghq.com)  agent
2. to send reports of puppet runs to the Datadog service [Datadog](http://www.datadoghq.com/).

Requirements
------------

Puppet >=2.7.x and <=4.2.x. For detailed informations on compatibility, check the [module page](https://forge.puppetlabs.com/datadog/datadog_agent) on the Puppet forge.

Installation
------------

Install `datadog_agent` as a module in your Puppet master's module path.

    puppet module install datadog-datadog_agent

### Upgrade from previous git manual install 0.x (unreleased)

You can keep using the `datadog` module but it becomes legacy with the release of `datadog_agent` 1.0.0. Upgrade to get new features, and use the puppet forge system which is way easier for maintenance.

* Delete the datadog module `rm -r /etc/puppet/modules/datadog`
* Install the new module from the puppet forge `puppet module install datadog-datadog_agent`
* Update your manifests with the new module class, basically replace `datadog` by `datadog_agent`

#### For instance to deploy the elasticsearch integration
    include 'datadog_agent::integrations::elasticsearch'

Usage
-----

Once the `datadog_agent` module is installed on your master, there's a tiny bit of configuration
that needs to be done.

1. Update the default class parameters with your [API key](https://app.datadoghq.com/account/settings#api)

2. Specify the module on any nodes you wish to install the DataDog
   Agent.

        include datadog_agent

  Or assign this module using the Puppet style Parameterized class:
        class { 'datadog_agent':
          api_key => "yourkey",
        }

  On your Puppet master, enable reporting:

        class { 'datadog_agent':
          api_key            => "yourkey",
          puppet_run_reports => true,
        }

  __To support reporting, your Puppet master needs to have the [dogapi](https://github.com/DataDog/dogapi-rb) gem installed, to do that either run the puppet agent on your master with this configuration or install it manually with `gem`__

3. Include any other integrations you want the agent to use, e.g.

        include 'datadog_agent::integrations::mongo'

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

This is the minimal set of modifications to get started. These files assume puppet 2.7.x or higher.

/etc/puppet/puppet.conf
-----------------------

    [master]
    report = true
    reports = datadog_reports
    pluginsync = true

    [agent]
    report = true
    pluginsync = true

/etc/puppet/manifests/nodes.pp
------------------------------

    node "default" {
        class { "datadog_agent":
            api_key => "INSERT YOU API KEY HERE",
        }
    }
    node "puppetmaster" {
        class { "datadog_agent":
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

![Puppet integration tile][puppet-integration-tile]

If you click on the tile, you may reconfirm it's been automatically installed.

![Puppet integration][puppet-integration]

[puppet-integration-tile]: https://raw.githubusercontent.com/DataDog/documentation/master/content/integrations/images/snapshot_puppet_tile.png

[puppet-integration]: https://raw.githubusercontent.com/DataDog/documentation/master/content/integrations/images/snapshot_puppet_integration.png

Search for "Puppet" in the Stream and you should see something like this:

![Puppet Events in Datadog][puppet-events]

[puppet-events]: https://raw.githubusercontent.com/DataDog/documentation/master/content/integrations/images/snapshot_puppet_events.png

Masterless puppet
=================

This is a specific setup, you can use https://gist.github.com/LeoCavaille/cd412c7a9ff5caec462f to set it up.

Module Development and Testing
==============================

### Clone the repo

```
git clone git@github.com:DataDog/puppet-datadog-agent.git
cd puppet-datadog-agent
```

### Install dependencies

```
bundle install
rake lint              # Check puppet manifests with puppet-lint / Run puppet-lint
rake spec              # Run spec tests in a clean fixtures directory
rake syntax            # Syntax check Puppet manifests and templates
rake syntax:manifests  # Syntax check Puppet manifests
rake syntax:templates  # Syntax check Puppet templates
pip install pre-commit
pre-commit install
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

