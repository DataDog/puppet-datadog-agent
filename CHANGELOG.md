Changes
=======


# 1.5.0 / 2015-11-13

### Notes

* [FEATURE] Add generic integration configuration
* [FEATURE] Add HTTPS support for yum and apt-get
* [FEATURE] Add support for warning on missing REDIS keys.
* [FEATURE] Add support for configuring the length of REDIS slow-query queue.
* [FEATURE] Add dogstatsd forwarding configuration.
* [FEATURE] Allow skipping of SSL validation.
* [FEATURE] Allow configuration of stats histogram percentiles.
* [FEATURE] Allow disabling apt-key trusting.
* [FEATURE] Add configuration of http client.
* [FEATURE] Add support for grabbing Hiera tags.

# 1.4.0 / 2015-09-14

### Notes

* [FEATURE] Add `ganglia` configuration
* [FEATURE] Add `rabbitmq` features for `queues` and `vhosts`
* [FEATURE] Add [pre-commit](http://www.pre-commit.com) hooks for `yaml` validation and `puppet-lint`

* [BUGFIX] Check for `rubygems` definition before attempting install
* [BUGFIX] Pin `rspec-puppet` version to 2.2.0 to avoid unexpected test regressions
* [BUGFIX] Fix default value for `ntp` offset
* [BUGFIX] Be more flexible in required version of `puppetlabs/ruby`
* [DOC] Improve documentation for `ntp` integration
* [DOC] Improve documentation for `postgres` integration
* [DOC] Improve documentation for contributing to the repo

# 1.3.0 / 2015-06-01

### Notes

* [FEATURE] Add `collect_ec2_tags` and `collect_instance_metadata` options to the main class
* [FEATURE] Add `sock` parameter in MySQL integration
* [FEATURE] Add support for graphite listener option in the main class
* [FEATURE] Add NTP integration
* [FEATURE] Add support for dogstreams array in the  main class
* [FEATURE] Add HAProxy integration
* [FEATURE] Add RabbitMQ integration
* [FEATURE] Add support for an extra template appended to datadog.conf
* [FEATURE] Add Mesos integration
* [FEATURE] Add Marathon integration
* [FEATURE] Add more flexiblity to configure the docker integration

* [BUGFIX] Fix discrepancy of `exact_match` default in the process check compared to dd-agent
* [BUGFIX] Fix ordering of resources when installing agent
* [CI] Test on a variety of puppet & ruby versions
* [CI] Move to Travis docker infra and add some bundle caching

# 1.2.0 / 2015-02-24

### Notes

* [FEATURE] Add zookeeper integration
* [FEATURE] Make redhat/yum base URL configurable
* [FEATURE] Add docker integration
* [FEATURE] Add postgres integration
* [FEATURE] Add `use_mount` option in the base datadog_agent class
* [FEATURE] Add proxy options in the base datadog_agent class
* [BUGFIX] Use correct JMX-styled tags in JMX integrations
> Careful this means that you probably have to update a buggy array of tags (that gives you nothing in the agent) to a hash of tags.

* [BUGFIX] Fix ordering in YAML templates using `to_yaml` broken because of ruby 1.8
* [CI] Add boilerpate for specs and linting rake tasks
* [CI] Add a travis build!
* [CI] All base manifests should have specs

# 1.1.1 / 2014-10-03

### Notes

* [FEATURE] Expose `log_to_syslog` in `datadog_agent` class
* [BUGFIX] Fix Mongo integration YAML file generation when using `tags`

# 1.1.0 / 2014-09-22

### Notes

* [FEATURE] Add `facts_to_tags` to the main class, to tag with facts out of the box
* [FEATURE] Add classes for Tomcat & Solr integrations
* [FEATURE] Make `service_ensure` and `service_enable` configurable allowing specific use like image builds
* [BUGFIX] Removed `datadog-agent-base` removal during installation that could cause yum to uninstall `datadog-agent`
* [BUGFIX] Fixed deprecation warning on the `datadog.conf` template

# 1.0.1
