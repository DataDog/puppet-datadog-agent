Changes
=======

# 1.7.0 / 2016-04-12

### Notes

* [FEATURE] Added manifest for PGBouncer. See [#175][]. (Thanks [@mcasper][]).
* [FEATURE] Added manifest for Consul. See [#174][]. (Thanks [@flyinprogrammer][]).
* [FEATURE] Added mesos master and slave manifests for individual management. See [#174][]. (Thanks [@flyinprogrammer][] and [@jangie][]).
* [FEATURE] Added option to extract the hostname from puppet hostname strings with a regex capture group. See [#173][]. (Thanks [@LeoCavaille][]).
* [FEATURE] Added support on multiple ports per host on Redis integration. See [#169][]. (Thanks [@fzwart][]).
* [FEATURE] Added support for `disable_ssl_validation` on Apache integration. See[#171. (Thanks [@BIAndrews][]).
* [FEATURE] Added support for SSL, additional metrics and database connection in Mongo integration. See [#164][]. (Thanks [@bflad][]).
* [FEATURE] Added support for multiple instance in HTTP check. See [#155][]. (Thanks [@bfla][]d].
* [FEATURE] Added support for multiple new datadog.conf directives. See [#79][]. (Thanks [@obowersa][]).
* [FEATURE] Decouple yum repo from agent package. See [#168][]. (Thanks [@b2jrock][]).

* [IMPROVEMENT] Moved GPG key to its own parameter. See [#158][]. (Thanks [@davidgibbons][]).

* [BUFIX] Updated docker to use more current `docker_daemon`. See [#174][]. (Thanks [@flyinprogrammer][] and [@jangie][]).

* [DEPRECATE] Deprecated old docker manifest. See [#174][]. (Thanks [@flyinprogrammer][]).
* [DEPRECATE] Deprecated `new_tag_names` in `docker_daemon` manifest. See [#174][]. (Thanks [@flyinprogrammer][]).
* [DEPRECATE] Deprecated `use_mount` option in base manifest. See [#174][]. (Thanks [@flyinprogrammer][]).

* [CI] Improved spec and docs. See [#79][]. (Thanks [@obowersa][]).
* [CI] Added multiple tests for integration classes. See [#145][]. (Thanks [@kitchen][]).

# 1.6.0 / 2016-01-20

### Notes

* [FEATURE] Added Puppet 4 support. See [#161][]. (Thanks [@grubernaut][]).
* [FEATURE] Added support for optional parameters in NTP integration. See [#139][]. (Thanks [@MartinDelta][]).

* [BIGFIX] Use ensure_packages(), to be more polite about apt-transport-https. See [#154][]. (Thanks [@rtyler][]).
* [BUGFIX] Fixed Zookeeper template. See [#150][] (Thanks [@tuxinaut][]).
* [BUGFIX] Raised priority of `changed` event types to normal - they'll now show in Datadog UI. See [#156][]. (Thanks [@rtyler][]).
* [BUGFIX] Require stdlib >=4.6 (provide `validate_integer()`). See [#161][]. (Thanks [@mrunkel-ut][]).

* [CI] Testable up to puppet 4.2. See [#161][]. (Thanks [@grubernaut][]).
* [COSMETIC] Removing trailing whitespace. See [#149][]. (Thanks [@tuxinaut][]).

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

<!--- The following link definition list is generated by PimpMyChangelog --->
[#79]: https://github.com/DataDog/puppet-datadog-agent/issues/79
[#139]: https://github.com/DataDog/puppet-datadog-agent/issues/139
[#145]: https://github.com/DataDog/puppet-datadog-agent/issues/145
[#149]: https://github.com/DataDog/puppet-datadog-agent/issues/149
[#150]: https://github.com/DataDog/puppet-datadog-agent/issues/150
[#154]: https://github.com/DataDog/puppet-datadog-agent/issues/154
[#155]: https://github.com/DataDog/puppet-datadog-agent/issues/155
[#156]: https://github.com/DataDog/puppet-datadog-agent/issues/156
[#158]: https://github.com/DataDog/puppet-datadog-agent/issues/158
[#161]: https://github.com/DataDog/puppet-datadog-agent/issues/161
[#164]: https://github.com/DataDog/puppet-datadog-agent/issues/164
[#168]: https://github.com/DataDog/puppet-datadog-agent/issues/168
[#169]: https://github.com/DataDog/puppet-datadog-agent/issues/169
[#171]: https://github.com/DataDog/puppet-datadog-agent/issues/171
[#173]: https://github.com/DataDog/puppet-datadog-agent/issues/173
[#174]: https://github.com/DataDog/puppet-datadog-agent/issues/174
[#175]: https://github.com/DataDog/puppet-datadog-agent/issues/175
[@BIAndrews]: https://github.com/BIAndrews
[@LeoCavaille]: https://github.com/LeoCavaille
[@MartinDelta]: https://github.com/MartinDelta
[@b2jrock]: https://github.com/b2jrock
[@bfla]: https://github.com/bfla
[@bflad]: https://github.com/bflad
[@davidgibbons]: https://github.com/davidgibbons
[@flyinprogrammer]: https://github.com/flyinprogrammer
[@fzwart]: https://github.com/fzwart
[@grubernaut]: https://github.com/grubernaut
[@jangie]: https://github.com/jangie
[@kitchen]: https://github.com/kitchen
[@mcasper]: https://github.com/mcasper
[@mrunkel-ut]: https://github.com/mrunkel-ut
[@obowersa]: https://github.com/obowersa
[@rtyler]: https://github.com/rtyler
[@tuxinaut]: https://github.com/tuxinaut