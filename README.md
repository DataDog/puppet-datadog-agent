Puppet & Datadog
================

[![Build Status](https://travis-ci.com/DataDog/puppet-datadog-agent.svg?branch=master)](https://travis-ci.com/DataDog/puppet-datadog-agent)
[![Puppet Forge](https://img.shields.io/puppetforge/v/datadog/datadog_agent.svg)](https://forge.puppetlabs.com/datadog/datadog_agent)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/datadog/datadog_agent.svg)](https://forge.puppetlabs.com/datadog/datadog_agent)


Description
-----------

A module to:

1. Install the [DataDog][1] Agent.
2. Send Puppet run reports to [Datadog][1].

Releases
--------

The current version of this Puppet module is compatible with Puppet >= 4.6.x. For users running on older versions of Puppet the legacy module, series 1.x, should support most use-cases.

The majority of users should be able to use the current version, as the Puppet versions supported in the 1.x series of the module have been EOL'd.

Some features might be back-ported if there's enough demand, but in general only maintenance is performed on the 1.x series of the module. Future feature development is performed on the newer Puppet module.

Version 2.x
-----------

## Requirements

For detailed information on compatibility, check the [module page][2] on the Puppet forge.

## Installation

Install `datadog_agent` as a module in your Puppet master's module path.

```
puppet module install datadog-datadog_agent
```

**Note**: For CentOS versions <7.0, specify the service provider as `upstart`:

```
class{ 'datadog_agent':
    service_provider => 'upstart'
  }
```

### Upgrade from the previous module version 1.x

Most of the manifests are backward compatible. However, there are important changes to the main manifest:

- By default Datadog Agent 6.x is installed.
  - To use Agent 5.x in your nodes set the `agent5_enable` boolean parameter to `True`.
- Enhanced support for our APM Tracing Agent.
- Enhanced support for our Process Agent.
- Enhanced support for additional `agent6` options.
- APM Tracing and Process Agents are now opt-in options and are disabled by default.
  - The main `datadog_agent` class has parameters to enable and configure the Agents easily.
- Increased granularity for apt/yum repo configuration.
- New location for Datadog Puppet reporting configuration.


Version 1.x
-----------

## Requirements

Puppet >=2.7.x and <=4.2.x. For detailed information on compatibility, check the [module page][2] on the Puppet forge.

## Installation

Install `datadog_agent` as a module in your Puppet master's module path.

```
puppet module install datadog-datadog_agent --version 1.12.1
```

### Upgrade from previous git manual install 0.x (unreleased)

You can keep using the `datadog` module but it becomes legacy with the release of `datadog_agent` 1.0.0. Upgrade to get new features, and use the Puppet forge system which is easier for maintenance.

* Delete the Datadog module `rm -r /etc/puppet/modules/datadog`
* Install the new module from the Puppet forge `puppet module install datadog-datadog_agent`
* Update your manifests with the new module class, basically replace `datadog` by `datadog_agent`

Usage
-----

The following instructions are for both Puppet module versions (1.x, 2.x).

Note: 2.x installs Agent v6 by default, whereas 1.x defaults to Agent v5.

Once the `datadog_agent` module is installed on your `puppetserver`/`puppetmaster`, follow these configuration steps:

1. Update the default class parameters with your [API key][3].

2. Specify the module on any nodes you wish to install the DataDog Agent.

    ```
    include datadog_agent
    ```

    Or assign this module using the Puppet style Parameterized class:

    ```
    class { 'datadog_agent':
        api_key => "<YOUR_DD_API_KEY>",
    }
    ```

    On your `puppetserver`, enable reporting:

    ```
    class { 'datadog_agent':
        api_key            => "<YOUR_DD_API_KEY>",
        puppet_run_reports => true,
    }
    ```

    - To support reporting, your Puppet master needs the [dogapi][4] gem installed. To install, either run the Puppet Agent on your master with this configuration or install it manually with `gem`. You might need to restart your `puppetserver` service for the freshly installed `dogapi-rb` gem to be picked up.
    - On version 2.x, `puppetserver_gem` is defined as a module dependency, it is installed automatically when the module is installed.
    - On version 1.x:
      - If you are on Puppet Enterprise or POSS (ie. >=3.7.0), there is a soft dependency for reporting on the `puppetserver_gem` module. Install with `puppet module install puppetlabs-puppetserver_gem` - installing manually with `gem` does *not* work.
      - You may install `dogapi-rb` with `gem` as the system-level Ruby is used.
      - The gem provider is configurable by setting it to `puppetserver_gem` (set by default on PE/POSS (>=3.7.0)) or `gem` if on older versions of Puppet.
        - For users running puppet in standalone/masterless mode you will need to set the `puppet_gem_provider` to `puppet_gem` (or `gem` depending on versions) to ensure the `dogapi-rb` is available.

3. Include any other integrations you want the agent to use, for example:

    ```
    include 'datadog_agent::integrations::mongo'
    ```

    Some integrations do not come as a dedicated class. To install one of them, add its configuration in the manifest. Below is an example for the `ntp` check:

    ```
    class { 'datadog_agent':
        api_key      => "<YOUR_DD_API_KEY>",
        integrations => {
            "ntp" => {
                init_config => {},
                instances => [{
                    offset_threshold => 30,
                }],
            },
        },
    }
    ```

Installing and pinning specific versions of integrations
--------------------------------------------------------

You can specify a given integration and version number to be installed by using `datadog_agent::install_integration`. This will use the `datadog-agent integration` command to ensure a specific integration is installed or uninstalled.

```
datadog_agent::install_integration { "mongo-1.9":
    ensure => present,
    integration_name => 'datadog-mongo',
    version => '1.9.0',
}
```

The field `ensure` can be either `present` (default) or `absent`, the later being useful to remove a previously pinned version of an integration.


Reporting
---------
Ensure `dogapi-rb` is available on your system as explained earlier.

To enable reporting of changes to the Datadog timeline, enable the report processor on your Puppet master, and enable reporting for your clients. The clients send a run report after each check-in back to the master.

Set the `puppet_run_reports` option to true in the node configuration manifest for your master:

```ruby
class { "datadog-agent":
    api_key => "<YOUR_DD_API_KEY>",
    puppet_run_reports => true
    # ...
}
```

On Puppet >=4.x the location for your configuration file is `/etc/puppetlabs/puppet/puppet.conf`.

On older Puppets, the location is `/etc/puppet/puppet.conf`.

Add these configuration options in the pertinent location:

```ini
[main]
# No need to modify this section
# ...

[master]
# Enable reporting to Datadog
reports=datadog_reports
# If you use other reports already, just add datadog_reports at the end
# reports=store,log,datadog_reports
# ...

[agent]
# ...
pluginsync=true
report=true
```

On all of your Puppet client nodes add the following in the same location:

```ini
[agent]
# ...
report=true
```

If you see the following, ensure `reports=datadog_reports` is defined in **[master]**, not **[main]**.

```
err: Could not send report:
Error 400 on SERVER: Could not autoload datadog_reports:
Class Datadog_reports is already defined in Puppet::Reports
```


Step-by-step
============

This is the minimal set of modifications to get started. These files assume Puppet 4.5.x or higher.

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
        api_key => "<YOUR_DD_API_KEY>",
    }
}
node "puppetmaster" {
    class { "datadog_agent":
        api_key            => "<YOUR_DD_API_KEY>",
        puppet_run_reports => true
    }
}
```

_Note: This may be file `/etc/puppet/manifests/nodes.pp` on older puppets_


Run Puppet Agent
----------------

```
sudo systemctl  /etc/init.d/puppetmaster restart
sudo puppet agent --onetime --no-daemonize --no-splay --verbose
```

Example response:

```
info: Retrieving plugin
info: Caching catalog for alq-linux.dev.datadoghq.com
info: Applying configuration version '1333470114'
notice: Finished catalog run in 0.81 seconds
```

Verify on Datadog
-----------------

1. Search for `puppet` on [the Integrations page][5]. The Puppet integration tile displays the install status.

2. Search for `sources:puppet` in the [Event Stream][6] to see your Puppet events.

Masterless Puppet
=================

To use this specific setup, see https://gist.github.com/LeoCavaille/cd412c7a9ff5caec462f. This applies to older puppets and is untested on >=4.x Puppet versions.


Client Settings
===============

### Tagging client nodes

The Datadog Agent configuration file is recreated from the template every Puppet run. If you need to tag your nodes, add an array entry in Hiera:

```
datadog_agent::tags:
- 'keyname:value'
- 'anotherkey:%{factname}'
```

These variables can be set in the `datadog_agent` class to control settings in the Agent:

#### 2.x

| variable name               | description                                                                                                                                                                                      |
|-----------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `collect_ec2_tags`          | Set this to yes to have an instance's custom EC2 tags used as agent tags.                                                                                                                        |
| `collect_instance_metadata` | Set this to yes to have an instance's EC2 metadata used as agent tags.                                                                                                                           |
| `datadog_site`              | The Datadog site to report to. Defaults to `datadoghq.com`, set to `datadoghq.eu` to report to the EU site. Supported since v2.4.0 of the module, and only with Agent v6+                         |
| `dd_url`                    | The Datadog intake server URL. You are unlikely to need to change this. Overrides `datadog_site`                                                                                     |
| `host`                      | Overrides the node's host name.                                                                                                                                                                  |
| `local_tags`                | An array of <KEY:VALUE> strings that are set as tags for the node.                                                                                                                               |
| `non_local_traffic`         | Set this to allow other nodes to relay their traffic through this one.                                                                                                                           |
| `agent5_enable`             | A boolean to install Agent v5 and override the Agent v6 default.                                                                                                                                 |
| `apm_enabled`               | A boolean to enable the APM Agent (defaults to false).                                                                                                                                           |
| `apm_analyzed_spans`        | A hash to add APM events for the Trace Search & Analytics tool. (defaults to undef). For example: `{ 'app\|rails.request' => 1, 'service-name\|operation-name' => 0.8 }`                         |
| `process_enabled`           | A boolean to enable the process agent (defaults to false).                                                                                                                                       |
| `scrub_args`                | A boolean to enable the process cmdline scrubbing (defaults to true).                                                                                                                            |
| `custom_sensitive_words`    | An array to add more words beyond the default ones used by the scrubbing feature (defaults to []).                                                                                               |
| `logs_enabled`              | A boolean to enable the logs agent (defaults to false).                                                                                                                                          |
| `container_collect_all`     | A boolean to enable logs collection for all containers.                                                                                                                                          |
| `agent6_extra_options`      | A hash to provide additional configuration options to Agent v6.                                                                                                                                  |
| `hostname_extraction_regex` | A regex used to extract the hostname captured group to report the run in Datadog instead of reporting the Puppet nodename, for example:<br>`'^(?<hostname>.*\.datadoghq\.com)(\.i-\w{8}\..*)?$'` |

##### Notes:

- `agent6_extra_options` is used to provide a fine grain control of additional Agent v6 config options. A deep merge is performed that may override options provided in the `datadog_agent` class parameters.
- `hostname_extraction_regex` is useful when the Puppet module and the Datadog Agent are reporting different host names for the same host in the infrastructure list.

#### 1.x

| variable name               | description                                                               |
|-----------------------------|---------------------------------------------------------------------------|
| `collect_ec2_tags`          | Set this to yes to have an instance's custom EC2 tags used as agent tags. |
| `collect_instance_metadata` | Set this to yes to have an instance's EC2 metadata used as agent tags.    |
| `dd_url`                    | The Datadog intake server URL. You are unlikely to need to change this.   |
| `host`                      | Overrides the node's host name.                                           |
| `local_tags`                | An array of <KEY:VALUE> strings that are set as tags for the node.        |
| `non_local_traffic`         | Set this to allow other nodes to relay their traffic through this one.    |
| `agent6_enable`             | A boolean to install Agent v6 and override the Agent v5 default.          |

### Proxy Settings

To connect to the Internet through a proxy, set `proxy_host`, `proxy_port`, `proxy_user` and `proxy_password`.


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
rake lint              # Check Puppet manifests with puppet-lint / Run puppet-lint
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


[1]: http://www.datadoghq.com
[2]: https://forge.puppetlabs.com/datadog/datadog_agent
[3]: https://app.datadoghq.com/account/settings#api
[4]: https://github.com/DataDog/dogapi-rb
[5]: https://app.datadoghq.com/account/settings#integrations
[6]: https://app.datadoghq.com/event/stream

