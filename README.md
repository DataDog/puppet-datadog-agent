# Datadog Puppet Module

This module installs the Datadog Agent and sends Puppet reports to Datadog.

## Setup

### Requirements

The Datadog Puppet module supports Linux and Windows and is compatible with Puppet >= 4.6.x or Puppet Enterprise version >= 2016.4. For detailed information on compatibility, check the [module page on Puppet Forge][1].

### Installation

Install the [datadog_agent][1] Puppet module in your Puppet master's module path:

```shell
puppet module install datadog-datadog_agent
```

**Note**: For CentOS/RHEL versions <7.0 and for Ubuntu < 15.04, specify the service provider as `upstart`:

```conf
class{ 'datadog_agent':
    service_provider => 'upstart'
  }
```

#### Upgrading

- By default Datadog Agent v7.x is installed. To use an earlier Agent version, change the setting `agent_major_version`.
- `agent5_enable` is no longer used, as it has been replaced by `agent_major_version`.
- `agent6_extra_options` has been renamed to `agent_extra_options` since it now applies to both Agent v6 and v7.
- `agent6_log_file` has been renamed to `agent_log_file` since it now applies to both Agent v6 and v7.
- `agent5_repo_uri` and `agent6_repo_uri` become `agent_repo_uri` for all Agent versions.
- `conf_dir` and `conf6_dir` become `conf_dir` for all Agent versions.
- The repository file created on Linux is now named `datadog` for all Agent versions instead of `datadog5`/`datadog6`.

### Configuration

Once the `datadog_agent` module is installed on your `puppetserver`/`puppetmaster` (or on a masterless host), follow these configuration steps:

1. Obtain your [Datadog API key][2].
2. Specify the module to install the Datadog Agent on your nodes.

   ```conf
   include datadog_agent
   ```

    Or assign this module using the Puppet style Parameterized class:

   ```conf
   class { 'datadog_agent':
       api_key => "<YOUR_DD_API_KEY>",
   }
   ```

3. On your `puppetserver`, enable reporting:

   ```conf
   class { 'datadog_agent':
       api_key            => "<YOUR_DD_API_KEY>",
       puppet_run_reports => true,
   }
   ```

    - To support reporting, your Puppet master needs the [dogapi][3] gem installed by running the Puppet Agent on your master with this configuration or installing it manually with `gem`. You may need to restart your `puppetserver` service after installing the `dogapi` gem.
    - `puppetserver_gem` is defined as a module dependency. It is installed automatically when the module is installed.

4. (Optional) Enable tagging of reports with facts
    You can add tags to reports that are sent to Datadog as events. These tags can be sourced from Puppet facts for the given node the report is regarding. These should be 1:1 and not involve structured facts (hashes, arrays, etc.) to ensure readability. To enable tagging, set the parameter `datadog_agent::reports::report_fact_tags` to the array value of facts—for example `["virtual","trusted.extensions.pp_role","operatingsystem"]` results in three separate tags per report event.

    NOTE: Changing these settings requires a restart of pe-puppetserver (or puppetserver) to re-read the report processor. Ensure the changes are deployed prior to restarting the service(s).

    Tips:
    - Use dot index to specify a target fact; otherwise, the entire fact data set becomes the value as a string (not very useful)
    - Do not duplicate common data from monitoring like hostname, uptime, memory, etc.
    - Coordinate core facts like role, owner, template, datacenter, etc., that help you build meaningful correlations to the same tags from metrics


5. (Optional) Include integrations to use with the Agent, for example:

   ```conf
   include 'datadog_agent::integrations::mongo'
   ```

    If an integration does not have a [manifest with a dedicated class][6], you can still add a configuration for it. Below is an example for the `ntp` check:

   ```conf
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

#### Integration versions

To install and pin specific integration versions, specify an integration and version number by using `datadog_agent::install_integration`. This uses the `datadog-agent integration` command to ensure a specific integration is installed or uninstalled, for example:

```conf
datadog_agent::install_integration { "mongo-1.9":
    ensure => present,
    integration_name => 'datadog-mongo',
    version => '1.9.0',
}
```

`ensure` has two options:

- `present` (default)
- `absent` (removes a previously pinned version of an integration)

### Reporting

Ensure the [dogapi][3] gem is available on your system.

To enable reporting of changes to your Datadog timeline, enable the report processor on your Puppet master and reporting for your clients. The clients send a run report after each check-in back to the master.

Set the `puppet_run_reports` option to true in the node configuration manifest for your master:

```ruby
class { "datadog-agent":
    api_key => "<YOUR_DD_API_KEY>",
    puppet_run_reports => true
    # ...
}
```

The Puppet configuration file is located in `/etc/puppetlabs/puppet/puppet.conf`.


Add these configuration options to the appropriate location:

```ini
[main]
# No modification needed to this section
# ...

[master]
# Enable reporting to Datadog
reports=datadog_reports
# If you use other reports, add datadog_reports to the end,
# for example: reports=store,log,datadog_reports
# ...

[agent]
# ...
pluginsync=true
report=true
```

On all of your Puppet client nodes, add the following in the same location:

```ini
[agent]
# ...
report=true
```

#### Troubleshooting

If you see the following error, ensure `reports=datadog_reports` is defined in `[master]`, not `[main]`.

```text
err: Could not send report:
Error 400 on SERVER: Could not autoload datadog_reports:
Class Datadog_reports is already defined in Puppet::Reports
```

### Step-by-step

This is the minimal set of modifications to get started.

1. Edit `/etc/puppetlabs/puppet/puppet.conf` to add the Puppet Agent:

    ```ini
    [master]
    report = true
    reports = datadog_reports
    pluginsync = true

    [agent]
    report = true
    pluginsync = true
    ```


2. Edit `/etc/puppetlabs/code/environments/production/manifests/10_nodes.pp` to configure your Agent:

    ```conf
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

     **Note**: For older versions of Puppet, edit `/etc/puppet/manifests/nodes.pp`.

3. Run the Puppet Agent:

    ```shell
    sudo systemctl restart puppetserver
    sudo puppet agent --onetime --no-daemonize --no-splay --verbose
    ```

     Example response:

    ```text
    info: Retrieving plugin
    info: Caching catalog for alq-linux.dev.datadoghq.com
    info: Applying configuration version '1333470114'
    notice: Finished catalog run in 0.81 seconds
    ```

4. Verify your Puppet data is in Datadog by searching for `sources:puppet` in the [Event Stream][5].

## Masterless Puppet

1. The Datadog module and its dependencies have to be installed on all nodes running masterless.
2. Add this to each node's `site.pp` file:
    ```conf
    class { "datadog_agent":
        api_key            => "<YOUR_DD_API_KEY>",
        puppet_run_reports => true
    }
   ```

3. Configure reports in the `[main]` section of `puppet.conf`:
    ```conf
    [main]
    reports=datadog_reports
    ```
4. Run puppet in masterless configuration:
    ```shell
    puppet apply --modulepath <path_to_modules> <path_to_site.pp>
    ```

## Client settings

### Tagging client nodes

The Datadog Agent configuration file is recreated from the template every Puppet run. If you need to tag your nodes, add an array entry in Hiera:

```conf
datadog_agent::tags:
- 'keyname:value'
- 'anotherkey:%{factname}'
```
To generate tags from custom facts classify your nodes with Puppet facts as an array to the ```facts_to_tags``` paramter either through the Puppet Enterprise console or Hiera. Here is an example:

```conf
class { "datadog_agent":
  api_key            => "<YOUR_DD_API_KEY>",
  facts_to_tags      => ["osfamily","networking.domain","my_custom_fact"],
}
```
Tips: 
1. For structured facts index into the specific fact value otherwise the entire array will come over as a string and ultimately be difficult to use.
2. Dynamic facts such as CPU usage, Uptime, and others that are expected to change each run are not ideal for tagging.  Static facts that are expected to stay for the life of a node are best candidates for tagging.

### Configuration variables

These variables can be set in the `datadog_agent` class to control settings in the Agent:

| variable name                           | description                                                                                                                                                                                      |
|-----------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `agent_major_version`                   | The version of the Agent to install: either 5, 6 or 7 (default: 7).                                                                                                                              |
| `agent_version`                         | Lets you pin a specific minor version of the Agent to install, for example: `1:7.16.0-1`. Leave empty to install the latest version.                                                             |
| `collect_ec2_tags`                      | Collect an instance's custom EC2 tags as Agent tags by using `true`.                                                                                                                             |
| `collect_instance_metadata`             | Collect an instance's EC2 metadata as Agent tags by using `true`.                                                                                                                                |
| `datadog_site`                          | The Datadog site to report to. Defaults to `datadoghq.com`, set to `datadoghq.eu` to report to the EU site (Agent v6 and v7 only).                                                               |
| `dd_url`                                | The Datadog intake server URL. You are unlikely to need to change this. Overrides `datadog_site`                                                                                                 |
| `host`                                  | Overrides the node's host name.                                                                                                                                                                  |
| `local_tags`                            | An array of `<KEY:VALUE>` strings that are set as tags for the node.                                                                                                                             |
| `non_local_traffic`                     | Allow other nodes to relay their traffic through this node.                                                                                                                                      |
| `apm_enabled`                           | A boolean to enable the APM Agent (defaults to false).                                                                                                                                           |
| `apm_analyzed_spans`                    | A hash to add APM events for trace search & analytics (defaults to undef), for example:<br>`{ 'app\|rails.request' => 1, 'service-name\|operation-name' => 0.8 }`                                |
| `process_enabled`                       | A boolean to enable the process Agent (defaults to false).                                                                                                                                       |
| `scrub_args`                            | A boolean to enable the process cmdline scrubbing (defaults to true).                                                                                                                            |
| `custom_sensitive_words`                | An array to add more words beyond the default ones used by the scrubbing feature (defaults to `[]`).                                                                                             |
| `logs_enabled`                          | A boolean to enable the logs Agent (defaults to false).                                                                                                                                          |
| `container_collect_all`                 | A boolean to enable logs collection for all containers.                                                                                                                                          |
| `agent_extra_options`<sup>1</sup>       | A hash to provide additional configuration options (Agent v6 and v7 only).                                                                                                                       |
| `hostname_extraction_regex`<sup>2</sup> | A regex used to extract the hostname captured group to report the run in Datadog instead of reporting the Puppet nodename, for example:<br>`'^(?<hostname>.*\.datadoghq\.com)(\.i-\w{8}\..*)?$'` |

(1) `agent_extra_options` is used to provide a fine grain control of additional Agent v6/v7 config options. A deep merge is performed that may override options provided in the `datadog_agent` class parameters.

(2) `hostname_extraction_regex` is useful when the Puppet module and the Datadog Agent are reporting different host names for the same host in the infrastructure list.

[1]: https://forge.puppet.com/datadog/datadog_agent
[2]: https://app.datadoghq.com/account/settings#api
[3]: https://github.com/DataDog/dogapi-rb
[4]: https://app.datadoghq.com/account/settings#integrations
[5]: https://app.datadoghq.com/event/stream
[6]: https://github.com/DataDog/puppet-datadog-agent/tree/master/manifests/integrations
