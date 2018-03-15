Puppet & Datadog
================

[![Build Status](https://travis-ci.org/DataDog/puppet-datadog-agent.svg?branch=master)](https://travis-ci.org/DataDog/puppet-datadog-agent)

Description
-----------

A module to:

1. install the [DataDog](http://www.datadoghq.com) agent
2. to send reports of puppet runs to the Datadog service [Datadog](http://www.datadoghq.com/).

Releases
--------

There are currently two actively maintained versions for the puppet module. To users on puppet >= 4.6.x, and possibly some older 4.x puppets, we recommend you use version 2.0+ of the module. 

For users running on older versions of puppet the legacy module, series 1.x, should support most use-cases. 

Hopefully a majority of users will be able to use the newer module as many of the puppet versions supported in the 1.x series of the module have been EOL'd for a while now.

Some features might be back-ported if there's enough demand for it, but in general only maintenance will be performed on the 1.x series of the module. Future feature development will be performed on the newer puppet module.


Version 2.x
-----------

## Requirements

Puppet >=4.6.x and <=5.3.x (we may work with newer versions, but untested). For detailed informations on compatibility, check the [module page](https://forge.puppetlabs.com/datadog/datadog_agent) on the Puppet forge.

## Installation

Install `datadog_agent` as a module in your Puppet master's module path.

    puppet module install datadog-datadog_agent

### Upgrade from the previous module version 1.x

Most of the manifests should be backward compatible. However, there are important changes to the main manifest:

- By default datadog agent 6.x will now be installed.
  - You may still setup agent 5.x in your nodes by seting the `agent5_enable` boolean parameter to `True`
- Enhanced support for our APM tracing agent
- Enhanced support for our Process agent
- Enhanced support for additional agent6 options
- APM tracing and Process agents are now opt-in options and will be disabled by default.
  - Main `datadog_agent` class has parameters to enable and configure the agents easily.
- Increased granularity for apt/yum repo configuration 
- New location for datadog puppet reporting configuration


Version 1.x
-----------

## Requirements

Puppet >=2.7.x and <=4.2.x (we may work with newer versions, but untested). For detailed informations on compatibility, check the [module page](https://forge.puppetlabs.com/datadog/datadog_agent) on the Puppet forge.

## Installation

Install `datadog_agent` as a module in your Puppet master's module path.

    puppet module install datadog-datadog_agent --version 1.12.1

### Upgrade from previous git manual install 0.x (unreleased)

You can keep using the `datadog` module but it becomes legacy with the release of `datadog_agent` 1.0.0. Upgrade to get new features, and use the puppet forge system which is way easier for maintenance.

* Delete the datadog module `rm -r /etc/puppet/modules/datadog`
* Install the new module from the puppet forge `puppet module install datadog-datadog_agent`
* Update your manifests with the new module class, basically replace `datadog` by `datadog_agent`


Usage
-----

The following instructions should hold true for both puppet module versions (1.x, 2.x).

Note: remember 2.x will install agent6 by default, whereas 1.x defaults to agent6.

Once the `datadog_agent` module is installed on your `puppetserver`/`puppetmaster`, there's a tiny bit of configuration
that needs to be done.

1. Update the default class parameters with your [API key](https://app.datadoghq.com/account/settings#api)

2. Specify the module on any nodes you wish to install the DataDog
   Agent.
        ```
        include datadog_agent
        ```

  Or assign this module using the Puppet style Parameterized class:
        ```
        class { 'datadog_agent':
          api_key => "yourkey",
        }
        ```

  On your `puppetserver`, enable reporting:

        ```
        class { 'datadog_agent':
          api_key            => "yourkey",
          puppet_run_reports => true,
        }
        ```

  __To support reporting, your Puppet master needs to have the [dogapi](https://github.com/DataDog/dogapi-rb) gem installed, to do that either run the puppet agent on your master with this configuration or install it manually with `gem`.__
  __Please note, you may have two restart your `puppetserver` service for the freshly installed `dogapi-rb` gem to be picked up.__
  _Please note, on version 2.x of the module `puppetserver_gem` is defined as a module dependency, it should be installed automatically when the module is installed._
  _Please note, on version 1.x and if on Puppet Enterprise or POSS (ie. >=3.7.0) there is a soft dependency for reporting on the `puppetserver_gem` module. Install with `puppet module install puppetlabs-puppetserver_gem` - installing manually with `gem` will *not* work._
  _Please note, on version 1.x and older puppets you may install `dogapi-rb` with `gem` as the system-level ruby is used_
  _Also note, on version 1.x of the puppet module, the gem provider is configurable, so you can set it to `puppetserver_gem` (already set by default) if on PE/POSS (>=3.7.0) or `gem` if on older versions of puppet_


3. Include any other integrations you want the agent to use, e.g.

        include 'datadog_agent::integrations::mongo'

Reporting
---------
Other than ensuring that dogapi-rb is available on your system as we 
explained earlier, a few additional steps should be conducted.

To enable reporting of changes to the Datadog timeline, enable the report
processor on your Puppet master, and enable reporting for your clients.
The clients will send a run report after each check-in back to the master.

Make sure you enable the `puppet_run_reports` option to true in the node
configuration manifest for your master.

```ruby
class { "datadog-agent":
    api_key => "<your_api_key>",
    puppet_run_reports => true
    # ...
}
```

On puppet >=4.x the location for your configuration file will be: 
`/etc/puppetlabs/puppet/puppet.conf`
On older puppets the location should be: `/etc/puppet/puppet.conf`

Add these configuration options in the pertinent location:

```ini
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
```

And on all of your Puppet client nodes add the following in the
same location::

```ini
[agent]
# ...
report=true
```

If you get

```
err: Could not send report:
Error 400 on SERVER: Could not autoload datadog_reports:
Class Datadog_reports is already defined in Puppet::Reports
```

Make sure `reports=datadog_reports` is defined in **[master]**, not **[main]**.


Step-by-step
============

This is the minimal set of modifications to get started. These files assume puppet 4.5.x or higher.

/etc/puppetlabs/puppet/puppet.conf
-----------------------
```ini
    [master]
    report = true
    reports = datadog_reports
    pluginsync = true

    [agent]
    report = true
    pluginsync = true
```

_Note: This may be file `/etc/puppet/puppet/puppet.conf` on older puppets_

/etc/puppetlabs/code/environments/production/manifests/10_nodes.pp
------------------------------

```
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
```

_Note: This may be file `/etc/puppet/manifests/nodes.pp` on older puppets_


Run Puppet Agent
----------------

    sudo systemctl  /etc/init.d/puppetmaster restart
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

This is a specific setup, you can use https://gist.github.com/LeoCavaille/cd412c7a9ff5caec462f to set it up. This applies to older puppets and is
untested on >=4.x puppet versions.

Client Settings
===============

### Tagging client nodes

The datadog agent configuration file will be recreated from the template every puppet run. If you need to tag your nodes, add an array entry in hiera

        datadog_agent::tags:
        - 'keyname:value'
        - 'anotherkey:%{factname}'

Here are some of the other variables that be set in the datadog_agent class to control settings in the agent:


#### 2.x

| variable name | description |
| ------------- | ----------- |
| collect_ec2_tags | Set this to yes to have an instance's custom EC2 tags used as agent tags |
| collect_instance_metadata | Set this to yes to have an instance's EC2 metadata used as agent tags |
| dd_url        | datadog intake server URL. You are unlikely to need to change this |
| host          | overrides the node's hostname |
| local_tags    | an array of key:value strings that will be set as tags for the node |
| non_local_traffic | set this to allow other nodes to relay their traffic through this one |
| agent5_enable | boolean to install agent5 and override agent6 default | 
| apm_enabled | boolean to enable the APM agent; defaults to true | 
| process_enabled | boolean to enable the process agent; defaults to true | 
| agent6_extra_options | hash to provide additional configuration options to agent6. | 

_NOTE: `agent6_extra_options` may be used to provide a fine grain control of additional agent6 config options. A deep merge is performed that may override options provided in the `datadog_agent` class parameters_


#### 1.x

| variable name | description |
| ------------- | ----------- |
| collect_ec2_tags | Set this to yes to have an instance's custom EC2 tags used as agent tags |
| collect_instance_metadata | Set this to yes to have an instance's EC2 metadata used as agent tags |
| dd_url        | datadog intake server URL. You are unlikely to need to change this |
| host          | overrides the node's hostname |
| local_tags    | an array of key:value strings that will be set as tags for the node |
| non_local_traffic | set this to allow other nodes to relay their traffic through this one |
| agent6_enable | boolean to install agent6 and override agent5 default | 

### Proxy Settings

If you need to connect to the internet through a proxy, you can set `proxy_host`, `proxy_port`, `proxy_user` and `proxy_password`.


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
