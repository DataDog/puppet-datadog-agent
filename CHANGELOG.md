Changes
=======

# 2.8.0 / 2019-09-18

### Notes

* [FEATURE] Initial Windows support. See [#557][]
* [FEATURE] Add ignore_ssl_warning to HTTP check. See [#556][] (Thanks [@zabacad][])
* [FEATURE] Add logs_open_files_limit parameter [#548][]. (Thanks [@rmrf-run][]))
* [BUGFIX] Fix a warning caused by calling `validate_legacy` with the default `additional_checksd` value of `undef`. See [#551][].
* [BUGFIX] Fix Redis integration, where tags weren't evaluated when the keys param was empty. See [#558][] (Thanks [@jubagarie][])
* [DOCUMENTATION] Fix doc for HTTP check include_content. See [#555][] (Thanks [@zabacad][])

# 2.7.0 / 2019-07-11

### Notes

* [FEATURE] Support puppet 6. See [#537][]
* [FEATURE] Added a define that wraps the agent integration command. See [#534][]
* [BUGFIX] Add whitespace surpression to redisdb.yaml.erb to ensure a valid yaml. See [#533][] (Thanks again [@Aramack][])
* [BUGFIX] Do not include additional_checksd if not set. See [#545][] (Thanks [@turnopil][])
* [IMPROVEMENT] Raise if hostname_extraction_regex doesn't capture hostname. See [#544][]

# 2.6.0 / 2019-06-04

### Notes

* [FEATURE] AcitveMQ_XML: added new integration. See [#521][]
* [FEATURE] Custom Integration: support logs collection. See [#513][] (Thanks [@zickzackv][])
* [FEATURE] Nginx: support logs collection. See [#519][] (Thanks [@jadams-av][])
* [FEATURE] Redis: adding multi-instance support. See [#520][]
* [FEATURE] HTTP check: add support for `method`, `data` configuration. See [#515][] (Thanks [@Aramack][])
* [FEATURE] HTTP check: add reverse content-match support. See [#524][] (Thanks [@dorg-kanderson][])
* [BUGFIX] Agent 6: track integration configuration directories - fixes `conf_dir_purge`. See [#525][] (Thanks [@Aramack][])
* [BUGFIX] Agent 6: fixes `additional_checksd` not appearing in agent config. See [#513][] (Thanks [@gotyaio][])
* [BUGFIX] Postgres: allow setting password in Hiera. See [#514][] (Thanks [@cabrinha][])
* [BUGFIX] Redis: fix trying to call `empty?` on an integer on template. See [#527][]
* [SANITY] Module: bring up concat dependency upper bound to <6.0.0. See [#516][] (Thanks [@siebrand][])
* [SANITY] Module: bring up stdlib dependency upper bound to <6.0.0. See [#513][] (Thanks [@skiedude][])
* [SANITY] Module: bring up apt dependency upper bound to <=6.0.0. See [#513][] (Thanks [@skiedude][])
* [DOCUMENTATION] Fixes on disk, ndingx and activemq_xml docs. See [#528][]

# 2.5.0 / 2019-03-25

### Notes

* [FEATURE] Kafka: Updated kafka integration to include all stats. See [#498][] (Thanks [@dpricha89][])
* [FEATURE] PostgreSQL: enable extra metrics collection. See [#493][] (Thanks [@diogokiss][])
* [FEATURE] Reporting: make gem provider configurable at the datadog-agent class level. See [#486][]
* [IMPROVEMENT] Disk: support new integration options replacing deprecations. See [#508][]
* [IMPROVEMENT] Remove apt-transport-https package install. See [#504][] (Thanks [@fr3nd][])
* [BUGFIX] Reporting: use https:// in datadog-reports.yaml. See [#503][] (Thanks [@cabrinha][])
* [BUGFIX] TCP check: `check_name` instead of name. See [#501][] (Thanks [@cabrinha][])
* [BUGFIX] SSH check: fix broken config location: `ssh_check.d` instead of `ssh.d`. See [#502][] (Thanks [@cabrinha][])
* [BUGFIX] Revert chatty apt-get update behavior. See [#506][] and [#507][]

# 2.4.1 / 2019-02-21

### Notes

* [FEATURE] APM Trace Search. See [#485][]
* [BUGFIX] Fix `apm_analyzed_spans` config directive. See [#496][] (Thanks [@zoom-kris-anderson][])
* [BUGFIX] Custom integration defined type bugfix. See [#490][] (Thanks [@o0oxid][])
* [DOCS] multiple documentation improvements. (See [#492][] and [#487][])

# 2.4.0 / 2018-12-27

### Notes

* [FEATURE] Support EU site in the reporter. See [#468][]
* [FEATURE] Add `datadog_site` for EU/USA region support. See [#464][]
* [FEATURE] Make Agent 6 `cmd_port` configurable. See [#473][] (Thanks [@arkpoah][])
* [FEATURE] Support backup keyservers. See [#470][]
* [FEATURE] Support `hostname_fqdn`. See [#481][] (Thanks [@alexfouche][])
* [FEATURE] Support GCE tag collection. See [#481][] (Thanks [@alexfouche][])
* [FEATURE] Tomcat: support `jmx_url` option. See [#482][] (Thanks [@evansj][])
* [IMPROVEMENT] Reports: fix `hostname_extraction_regex` default to undef. See [#482][] (Thanks [@evansj][])
* [IMPROVEMENT] Use recommended locations for integration configs. See [#481][] (Thanks [@alexfouche][])
* [IMPROVEMENT] Silence agent6_extra_options notification on default params. See [#449][] (Thanks [@spectralblu][])
* [IMPROVEMENT] Improve proxy argument management. See [#484][]
* [IMPROVEMENT] Generic integrations improvements. See [#471][]
* [BUGFIX] Fix potential dependency cycle when used with other modules. See [#463][]
* [BUGFIX] Fix Hiera tag merge in process integration. See [#481][] (Thanks [@alexfouche][])
* [BUGFIX] Merge `datadog_agent::tags` hiera values. See [#472][] (Thanks [@paulhamby][])
* [BUGFIX] Fix `apm_enabled` YAML. See [#466][] (Thanks [@NoodlesNZ][])
* [BUGFIX] Fix `facts_to_tags` regression in Agent 6. See [#455][] (Thanks [@tommoyangn][])
* [TEST] Removing `sudo: false` as required by Travis CI. See [#475][]
* [TEST] Adding vagrant-based test environment facilities. See [#462][]

# 2.3.0 / 2018-07-11

### Notes

* [FEATURE] Logs: enable log configuration management. See [#439][]
* [FEATURE] MySQL: enable custom queries/metrics. See [#316][] (Thanks [@yrcjaya][])
* [FEATURE] PHP-fpm: add parameter for ping-reply. See [#417][] (Thanks [@Aramack][])
* [FEATURE] Agents: allow version pinning from the main manifest. See [#446][]
* [BUGFIX] Agent 5: fix user/group override for config file. See [#438][] (Thanks [@arkpoah][])
* [BUGFIX] Agent 6: honor statsd forwarding parameters. See [#408][] (Thanks [@djova][])
* [BUGFIX] Agent 6: honor hostname configuration override. See [#445][]
* [BUGFIX] Agent 6: honor `collect_ec2_tags` parameter. See [#446][]
* [BUGFIX] Agents: (Amazon Linux bug) allow service provider override. See [#444][]
* [BUGFIX] Network: fix configuration path. See [#433][] (Thanks [@ewansteele][])
* [BUGFIX] Reporting: fix `hostname_extraction_regex` config option. See [#443][] (Thanks [@ColinHerbert][])
* [DEPRECATED] Agent 6: `proxy_*` options are deprecated use `agent6_extra_options`. See [#446][]
* [DOCS] README: fix apm, process config options. See [#437][] (Thanks [@pulkitsethi][])

# 2.2.0 / 2018-05-16

### Notes

* [FEATURE] APM: enable apm non-local traffic. See [#431][] (Thanks [@dschaaff][])
* [FEATURE] APM: add environment config parameter. See [#431][] (Thanks [@dschaaff][])
* [FEATURE] Process: add config fields for process agent scrubbing. See [#426][]
* [FEATURE] HTTP check: allow specification of CA cert. See [#418][] (Thanks [@ffleming][])
* [BUGFIX] PgBouncer: fix indentation in output configuration file. See [#427][] (Thanks [@fwelschen][])
* [BUGFIX] Process: fixes bad enabling directive. See [#420][] (Thanks [@dschaaff][])
* [BUGFIX] MySQL check: render port number correctly in output YAML. See [#424][] (Thanks [@kevin-bowers][])
* [DEPRECATE] DEB: stop installing old APT key. See [#406][]

# 2.1.1 / 2018-03-14

### Notes

* [BUGFIX] RHEL: fix faulty check prompting agent reinstalls. See [#412][] (Thanks [@jcarr-sailthru][])
* [BUGFIX] MySQL: fix broken parameters to manifest. See [#411][]

# 2.1.0 / 2018-03-06

### Notes

* [FEATURE] Kafka: support multiple instances. See [#404][]
* [FEATURE] Consul: add network latency check support. See [#394][] (Thanks [@Aramack][])
* [BUGFIX] Stdlib: fix deprecations after stdlib 4.24.0. See [#403][] and [#404][] (Thanks [@teintuc][])
* [BUGFIX] RHEL: stop specifying service resource provider `redhat`. See [#401][] (Thanks [@milescrabill][])
* [IMPROVEMENT] Add types to multiple manifest parameters. See [#404][]
* [COMPATIBILITY] Drop puppetlabs-apt dependency lower bound to `2.4.0`. See [#404][] and 400 (Thanks [@samueljamesmarshall][])

# 2.0.1 / 2018-02-28

### Notes

* [BUGFIX] RHEL: fix bad default agent6 repo url. See [#397][]

# 2.0.0 / 2018-02-27

### Overview
This release is a mejor release, there are a some breaking changes. We have
tried to keep the interface as similar as possible to what the community
was already used to, but have had to make some changes and cleaned up some
of the interfaces to some classes. Most notably the main `datadog_agent`
class, and the `datadog_agent::ubuntu` and `datadog_agent::redhat`.

Most checks manifest should remain backward compatible.

Please note this new release will install datadog agent version 6.x by default.

Finally, deprecated modules and support for EOL'd puppets has been dropped
so if you're running a puppet server <= `4.5.x` or PE <= `2016.4.x` although
the module might work for some versions, it has not been tested in those
environments.

Please read the [docs]() for more details.

### Notes

* [MAJOR] Datadog agent defaults to 6.x. Puppet >=4.6. See [#387][] and [docs](https://github.com/DataDog/puppet-datadog-agent/blob/master/README.md)
* [FEATURE] Postgresl: adding SSL parameter support. See [#391][] (thanks [@com6056][])
* [FEATURE] Docker_daemon: parametrize integration. See [#378][] (thanks [@flyinprogrammer][])
* [FEATURE] Kafka: added support for multiple instances. See [#343][], [#395][] (thanks [@jensendw][])
* [BUGFIX] Tomcat: fix broken metrics yaml. See [#390][] (thanks [@oshmyrko][])
* [BUGFIX] Agent6: fix Agent6 beta fact. See [#384][] (thanks [@scottgeary][])
* [CI] APM: fix APM spec tests. See [#389][]
* [CI] APM: do not apply footer if empty string. See [#381][] (thanks [@rothgar][])

# 1.12.1 / 2017-12-29

### Notes

* [BUGFIX] agent6: fix generated YAML. See [#379][]

# 1.12.0 / 2017-12-13

### Notes

* [FEATURE] agent6 beta support. See [#356][]
* [FEATURE] directory integration. See [#357][] (thanks [@alexfouche][])
* [FEATURE] linux_proc_extras integration. See [#357][] (thanks [@alexfouche][])
* [FEATURE] kafka integration. See [#357][] (thanks [@alexfouche][])
* [FEATURE] kubernetes integration. See [#369][] (thanks [@lowkeyshift][])
* [FEATURE] kuberentes_state integration. See [#369][] (thanks [@lowkeyshift][])
* [FEATURE] network integration. See [#346][] (thanks [@jameynelson][])
* [FEATURE] system core integration. See [#359][] (thanks [@dan70402][])
* [FEATURE] support for process_agent. See [#352][] (thanks [@jfrost][])

* [IMPROVEMENT] better support for puppet 4, 5. See [#362][] and [#370][] (thanks [@bittner][])
* [IMPROVEMENT] explicit puppet 5 support + fixes. See [#377][]
* [IMPROVEMENT] pgbouncer: support multiple instances. See [#361][] (thanks [@ajvb][])
* [IMPROVEMENT] general cleanup. See [#357][] and [#376][] (thanks [@alexfouche][])

* [BUGFIX] agent6: fix downgrade back to agent5 if on `latest` version. See [#375][]
* [BUGFIX] apt: only grep for last 8 characters to verify key. See [#373][] and [#374][] (thanks [@szponek][])

* [DOCUMENTATION] fix tagging documentation. See [#347][] (thanks [@bit-herder][])

# 1.11.0 / 2017-07-27

### Notes

* [FEATURE] Postfix Added integration. See [#323][] (Thanks [@npaufler][])
* [FEATURE] Twemproxy: Added integration. See [#326][] (Thanks [@swwolf][])
* [FEATURE] HAproxy: Added integration. See [#326][] (Thanks [@swwolf][])

* [IMPROVEMENT] Memcache: Add multi-instance support for memcache. See [#318][] (Thanks [@npaufler][])
* [IMPROVEMENT] Elasticsearch: Add support for multiple instances. See [#333][] (Thanks [@stantona][])
* [IMPROVEMENT] Mongodb: support collection metrics per collection. See [#335][] (Thanks [@jensendw][])
* [IMPROVEMENT] Redis: Allow command_stats. See [#327][] (Thanks [@IanCrouch][])
* [IMPROVEMENT] Ceph: Add parameters to integration. See [#322][] (Thanks [@stamak][])
* [IMPROVEMENT] Ubuntu: apt make repository configurable. See [#340][]
* [IMPROVEMENT] Ubuntu: use full key ID when adding GPG keys. See [#329][] (Thanks [@pid1][])
* [IMPROVEMENT] Dd-agent: Change owner/group of /etc/dd-agent. See [#325][] (Thanks [@ColinHebert][])
* [IMPROVEMENT] Docker_daemon: remove spaces that break resulting yaml. See [#336][] (Thanks [@ckolos][])

* [BUGFIX] Dd-agent: add extra_template back. See [#331][] (Thanks [@flyinprogrammer][])
* [BUGFIX] Dd-agent: Don't fail if there is no value in hiera. See [#334][] (Thanks [@mtougeron][])
* [BUGFIX] Core: Addressing metaparam override in datadog_agent::tag. See [#338][] (Thanks [@craigwatson][])
* [BUGFIX] RHEL/CentOS: fix chatty behavior. See [#341][]
* [BUGFIX] Dd-agent: ensured etc/dd-agent is directory. See [#332][] (Thanks [@butangero][])

* [SANITY] Metadata: set correct apache license ID.

# 1.10.0 / 2017-04-21

### Notes

* [FEATURE] Ceph: Adding integration. See [#293][] (Thanks [@stamak][])
* [FEATURE] Tcp_check: Adding integration. See [#286][] (Thanks [@aepod][])
* [FEATURE] Trace_agent: Configure APM trace agent. See [#302][] and [#311][] (Thanks [@DDRBoxman][])
* [FEATURE] Allow hiera defined integrations. See [#261][] (Thanks [@cwood][])

* [IMPROVEMENT] Make tags their own resource. See [#261][] (Thanks [@cwood][])
* [IMPROVEMENT] Support ports as integers. See [#315][] (Thanks [@alexharv074][])
* [IMPROVEMENT] PHPfpm: Support for multiple instances and `http_host`. See [#299][] (Thanks [@obi11235][])
* [IMPROVEMENT] RabbitMQ: Adding additional configuration parameters. See [#288][] (Thanks [@alvin-huang][])
* [IMPROVEMENT] Http_check: Adding response_status_code. See [#290][] (Thanks [@dzinek][])
* [IMPROVEMENT] Http_check: Adding no_proxy configuration option. See [#309][]
* [IMPROVEMENT] Service_discovery: Adding jmx checks for SD. See [#296][] (Thanks [@alvin-huang][])
* [IMPROVEMENT] Reporting: Fix already initialized warning. See [#292][] and [#310][] (Thanks [@craigwatson][])
* [IMPROVEMENT] Reporting: Send metrics for hosts as a batch, reducing overhead. See [#313][] (Thanks [@tdm4][])

* [DEPRECATE] Http_check: Slowly deprecate skip_event. See [#291][] (Thanks [@flyinprogrammer][])

* [DOCUMENTATION] Cleanup EC2-related parameter docs. See [#252][] (Thanks [@jdavisp3][])
* [DOCUMENTATION] Zookeeper: fix comment to match reality. See [#297][] (Thanks [@generica][])


# 1.9.0 / 2016-12-20

### Notes

* [BUGFIX] [rpm] fix key rotation for RPMs - install legacy key as well. See [#283][]. (Thanks [@aepod][]).
* [BUGFIX] Reporting: allow the report processor to run on Puppet Enterprise. See [#266][]. (Thanks [@binford2k][]).
* [BUGFIX] RHEL/CentOS: Fix gpg and test binary paths. See [#259][]. (Thanks [@sethcleveland][]).
* [BUGFIX] NTP: fix template. See [#280][]. (Thanks [@MartinDelta][]).
* [BUGFIX] Multiple integrations: swapped order of optional vs. non-optional parameters. See [#232][]. (Thanks [@sethcleveland][]).

* [IMPROVEMENT] [rpm+deb] repo keys rotated. See [#242][].
* [IMPROVEMENT] MySQL: Allow multiple MySQL instances See [#267][]. (Thanks [@IanCrouch][]).
* [IMPROVEMENT] Http check: `allow_redirects` + `check_certificate_expiration` improvement. See [#282][]. (Thanks [@cristianjuve][]).
* [IMPROVEMENT] Http_check: update to include new attributes. See [#276][]. (Thanks [@aepod][]).
* [IMPROVEMENT] Http_check: set disable_ssl_validation parameter. See [#258][].
* [IMPROVEMENT] Postgres: support generic postgres custom metrics. See [#224][]. (Thanks [@sethcleveland][]).
* [IMPROVEMENT] Postgres: support use_pscopg2 flag for postgres integrations. See [#243][]. (Thanks [@sethcleveland][]).
* [IMPROVEMENT] Cassandra: support cassandra integration tags. See [#256][]. (Thanks [@sethcleveland][]).
* [IMPROVEMENT] HAProxy: support multiple instances. See [#279][]. (Thanks [@swwolf][]).

* [FEATURE] Service Discovery: Allow Service Discovery configuration See [#281][]. (Thanks [@scottgeary][]).
* [FEATURE] Disk integration. See [#263][]. (Thanks [@denmat][]).
* [FEATURE] Cacti integration. See [#247][]. (Thanks [@sambanks][]).
* [FEATURE] JMX integration. See [#231][]. (Thanks [@rooprob][]).
* [FEATURE] Generic define to enable new integrations. See [#233][]. (Thanks [@cwood][])

* [CI] Multiple fixes related to the spec tests on older puppets.
* [CI] Consul: adding spec tests. See [#264][]. (Thanks [@flyinprogrammer][]).



# 1.8.1 / 2016-08-15

### Notes

* [BUGFIX] Updating Changelog and README.

# 1.8.0 / 2016-08-15

### Notes

* [FEATURE] Cassandra integration. See [#195][]. (Thanks [@aaron-miller][]).
* [FEATURE] Fluentd integration. See [#197][]. (Thanks [@aaron-miller][]).
* [FEATURE] Memcached integration. See [#203][]. (Thanks [@NoodlesNZ][]).
* [FEATURE] Riak integration. See [#213][]. (Thanks [@cristianjuve][]).
* [FEATURE] Supervisord integration. See [#214][]. (Thanks [@cristianjuve][]).
* [FEATURE] Kong integration. See [#215][]. (Thanks [@eddmann][]).
* [FEATURE] SSH integration. See [#219][]. (Thanks [@aaron-miller][]).
* [FEATURE] DNS integration. See [#212][]. (Thanks [@jacobbednarz][]).

* [IMPROVEMENT] MySQL: adding new mysql options. See [#216][]. (Thanks [@IanCrouch][]).
* [IMPROVEMENT] Elasticsearch: adding elasticsearch shield support. See [#202][]. (Thanks [@pabrahamsson][]).
* [IMPROVEMENT] Update the report config file check to account for permissions. See [#205][]. (Thanks [@mcasper][]).
* [IMPROVEMENT] Ubuntu: Use HTTPS for apt requests. See [#208][]. (Thanks [@jacobbednarz][]).
* [IMPROVEMENT] Ubuntu: retry `apt-get update`. See [#207][]. (Thanks [@mraylu][]).
* [IMPROVEMENT] Reporting: allow setting `dogapi` version. See [#210][]. (Thanks [@degemer][]).
* [IMPROVEMENT] Reporting: allow setting `gem_provider` manually. See [#223][].
* [IMPROVEMENT] Http_check: Adding content_match argument. See [#217][]. (Thanks [@cristianjuve][])
* [IMPROVEMENT] Varnish: Add `-n` argument. See [#209][]. (Thanks [@cristianjuve][])
* [IMPROVEMENT] Consul: new configuration options. See [#204][]. (Thanks [@scottgeary][])

* [BUGFIX] Reporting could break if `m` in datadog_reports returns nil. See [#211][].
* [BUGFIX] Redhat: Setting provider to `redhat`, should fix init issues. See [#222][].

* [CI] Fixed broken Travis testing.

# 1.7.1 / 2016-06-22

### Notes

* [BUFIX] Fix reversed logic in `hostname_extraction` option.. See [#189][]. (Thanks [@davejrt][]).
* [BUFIX] Fix reporting on PE and POSS. Dogapi gem required in JRuby Env. See [#188][].
* [BUFIX] On ubuntu manifest, agent version should be explicitly configurable. See [#187][].
* [BUFIX] HTTP check, name is a compulsory field. See [#186][].
* [BUFIX] Dogstatsd should be enabled by default. See [#183][].

# 1.7.0 / 2016-04-12

### Notes

* [FEATURE] Added manifest for PGBouncer. See [#175][]. (Thanks [@mcasper][]).
* [FEATURE] Added manifest for Consul. See [#174][]. (Thanks [@flyinprogrammer][]).
* [FEATURE] Added mesos master and slave manifests for individual management. See [#174][]. (Thanks [@flyinprogrammer][] and [@jangie][]).
* [FEATURE] Added option to extract the hostname from puppet hostname strings with a regex capture group. See [#173][]. (Thanks [@LeoCavaille][]).
* [FEATURE] Added support on multiple ports per host on Redis integration. See [#169][]. (Thanks [@fzwart][]).
* [FEATURE] Added support for `disable_ssl_validation` on Apache integration. See[#171. (Thanks [@BIAndrews][]).
* [FEATURE] Added support for SSL, additional metrics and database connection in Mongo integration. See [#164][]. (Thanks [@bflad][]).
* [FEATURE] Added support for multiple instance in HTTP check. See [#155][]. (Thanks [@jniesen][]).
* [FEATURE] Added support for multiple new datadog.conf directives. See [#79][]. (Thanks [@obowersa][]).
* [FEATURE] Decouple yum repo from agent package. See [#168][]. (Thanks [@b2jrock][]).

* [IMPROVEMENT] Moved GPG key to its own parameter. See [#158][]. (Thanks [@davidgibbons][]).

* [BUFIX] Updated docker to use more current `docker_daemon`. See [#174][]. (Thanks [@flyinprogrammer][] and [@jangie][]).

* [DEPRECATE] Deprecated old docker manifest. See [#174][]. (Thanks [@flyinprogrammer][]).
* [DEPRECATE] Deprecated `new_tag_names` in `docker_daemon` manifest. See [#176][].
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

[docs]: https://github.com/DataDog/puppet-datadog-agent/blob/master/README.md

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
[#176]: https://github.com/DataDog/puppet-datadog-agent/issues/176
[#183]: https://github.com/DataDog/puppet-datadog-agent/issues/183
[#186]: https://github.com/DataDog/puppet-datadog-agent/issues/186
[#187]: https://github.com/DataDog/puppet-datadog-agent/issues/187
[#188]: https://github.com/DataDog/puppet-datadog-agent/issues/188
[#189]: https://github.com/DataDog/puppet-datadog-agent/issues/189
[#195]: https://github.com/DataDog/puppet-datadog-agent/issues/195
[#197]: https://github.com/DataDog/puppet-datadog-agent/issues/197
[#202]: https://github.com/DataDog/puppet-datadog-agent/issues/202
[#203]: https://github.com/DataDog/puppet-datadog-agent/issues/203
[#204]: https://github.com/DataDog/puppet-datadog-agent/issues/204
[#205]: https://github.com/DataDog/puppet-datadog-agent/issues/205
[#207]: https://github.com/DataDog/puppet-datadog-agent/issues/207
[#208]: https://github.com/DataDog/puppet-datadog-agent/issues/208
[#209]: https://github.com/DataDog/puppet-datadog-agent/issues/209
[#210]: https://github.com/DataDog/puppet-datadog-agent/issues/210
[#211]: https://github.com/DataDog/puppet-datadog-agent/issues/211
[#212]: https://github.com/DataDog/puppet-datadog-agent/issues/212
[#213]: https://github.com/DataDog/puppet-datadog-agent/issues/213
[#214]: https://github.com/DataDog/puppet-datadog-agent/issues/214
[#215]: https://github.com/DataDog/puppet-datadog-agent/issues/215
[#216]: https://github.com/DataDog/puppet-datadog-agent/issues/216
[#217]: https://github.com/DataDog/puppet-datadog-agent/issues/217
[#219]: https://github.com/DataDog/puppet-datadog-agent/issues/219
[#222]: https://github.com/DataDog/puppet-datadog-agent/issues/222
[#223]: https://github.com/DataDog/puppet-datadog-agent/issues/223
[#224]: https://github.com/DataDog/puppet-datadog-agent/issues/224
[#231]: https://github.com/DataDog/puppet-datadog-agent/issues/231
[#232]: https://github.com/DataDog/puppet-datadog-agent/issues/232
[#233]: https://github.com/DataDog/puppet-datadog-agent/issues/233
[#242]: https://github.com/DataDog/puppet-datadog-agent/issues/242
[#243]: https://github.com/DataDog/puppet-datadog-agent/issues/243
[#247]: https://github.com/DataDog/puppet-datadog-agent/issues/247
[#252]: https://github.com/DataDog/puppet-datadog-agent/issues/252
[#256]: https://github.com/DataDog/puppet-datadog-agent/issues/256
[#258]: https://github.com/DataDog/puppet-datadog-agent/issues/258
[#259]: https://github.com/DataDog/puppet-datadog-agent/issues/259
[#261]: https://github.com/DataDog/puppet-datadog-agent/issues/261
[#263]: https://github.com/DataDog/puppet-datadog-agent/issues/263
[#264]: https://github.com/DataDog/puppet-datadog-agent/issues/264
[#266]: https://github.com/DataDog/puppet-datadog-agent/issues/266
[#267]: https://github.com/DataDog/puppet-datadog-agent/issues/267
[#276]: https://github.com/DataDog/puppet-datadog-agent/issues/276
[#279]: https://github.com/DataDog/puppet-datadog-agent/issues/279
[#280]: https://github.com/DataDog/puppet-datadog-agent/issues/280
[#281]: https://github.com/DataDog/puppet-datadog-agent/issues/281
[#282]: https://github.com/DataDog/puppet-datadog-agent/issues/282
[#283]: https://github.com/DataDog/puppet-datadog-agent/issues/283
[#286]: https://github.com/DataDog/puppet-datadog-agent/issues/286
[#288]: https://github.com/DataDog/puppet-datadog-agent/issues/288
[#290]: https://github.com/DataDog/puppet-datadog-agent/issues/290
[#291]: https://github.com/DataDog/puppet-datadog-agent/issues/291
[#292]: https://github.com/DataDog/puppet-datadog-agent/issues/292
[#293]: https://github.com/DataDog/puppet-datadog-agent/issues/293
[#296]: https://github.com/DataDog/puppet-datadog-agent/issues/296
[#297]: https://github.com/DataDog/puppet-datadog-agent/issues/297
[#299]: https://github.com/DataDog/puppet-datadog-agent/issues/299
[#302]: https://github.com/DataDog/puppet-datadog-agent/issues/302
[#309]: https://github.com/DataDog/puppet-datadog-agent/issues/309
[#310]: https://github.com/DataDog/puppet-datadog-agent/issues/310
[#311]: https://github.com/DataDog/puppet-datadog-agent/issues/311
[#313]: https://github.com/DataDog/puppet-datadog-agent/issues/313
[#315]: https://github.com/DataDog/puppet-datadog-agent/issues/315
[#316]: https://github.com/DataDog/puppet-datadog-agent/issues/316
[#318]: https://github.com/DataDog/puppet-datadog-agent/issues/318
[#322]: https://github.com/DataDog/puppet-datadog-agent/issues/322
[#323]: https://github.com/DataDog/puppet-datadog-agent/issues/323
[#325]: https://github.com/DataDog/puppet-datadog-agent/issues/325
[#326]: https://github.com/DataDog/puppet-datadog-agent/issues/326
[#327]: https://github.com/DataDog/puppet-datadog-agent/issues/327
[#329]: https://github.com/DataDog/puppet-datadog-agent/issues/329
[#331]: https://github.com/DataDog/puppet-datadog-agent/issues/331
[#332]: https://github.com/DataDog/puppet-datadog-agent/issues/332
[#333]: https://github.com/DataDog/puppet-datadog-agent/issues/333
[#334]: https://github.com/DataDog/puppet-datadog-agent/issues/334
[#335]: https://github.com/DataDog/puppet-datadog-agent/issues/335
[#336]: https://github.com/DataDog/puppet-datadog-agent/issues/336
[#338]: https://github.com/DataDog/puppet-datadog-agent/issues/338
[#340]: https://github.com/DataDog/puppet-datadog-agent/issues/340
[#341]: https://github.com/DataDog/puppet-datadog-agent/issues/341
[#343]: https://github.com/DataDog/puppet-datadog-agent/issues/343
[#346]: https://github.com/DataDog/puppet-datadog-agent/issues/346
[#347]: https://github.com/DataDog/puppet-datadog-agent/issues/347
[#352]: https://github.com/DataDog/puppet-datadog-agent/issues/352
[#356]: https://github.com/DataDog/puppet-datadog-agent/issues/356
[#357]: https://github.com/DataDog/puppet-datadog-agent/issues/357
[#359]: https://github.com/DataDog/puppet-datadog-agent/issues/359
[#361]: https://github.com/DataDog/puppet-datadog-agent/issues/361
[#362]: https://github.com/DataDog/puppet-datadog-agent/issues/362
[#369]: https://github.com/DataDog/puppet-datadog-agent/issues/369
[#370]: https://github.com/DataDog/puppet-datadog-agent/issues/370
[#373]: https://github.com/DataDog/puppet-datadog-agent/issues/373
[#374]: https://github.com/DataDog/puppet-datadog-agent/issues/374
[#375]: https://github.com/DataDog/puppet-datadog-agent/issues/375
[#376]: https://github.com/DataDog/puppet-datadog-agent/issues/376
[#377]: https://github.com/DataDog/puppet-datadog-agent/issues/377
[#378]: https://github.com/DataDog/puppet-datadog-agent/issues/378
[#379]: https://github.com/DataDog/puppet-datadog-agent/issues/379
[#381]: https://github.com/DataDog/puppet-datadog-agent/issues/381
[#384]: https://github.com/DataDog/puppet-datadog-agent/issues/384
[#387]: https://github.com/DataDog/puppet-datadog-agent/issues/387
[#389]: https://github.com/DataDog/puppet-datadog-agent/issues/389
[#390]: https://github.com/DataDog/puppet-datadog-agent/issues/390
[#391]: https://github.com/DataDog/puppet-datadog-agent/issues/391
[#394]: https://github.com/DataDog/puppet-datadog-agent/issues/394
[#395]: https://github.com/DataDog/puppet-datadog-agent/issues/395
[#397]: https://github.com/DataDog/puppet-datadog-agent/issues/397
[#401]: https://github.com/DataDog/puppet-datadog-agent/issues/401
[#403]: https://github.com/DataDog/puppet-datadog-agent/issues/403
[#404]: https://github.com/DataDog/puppet-datadog-agent/issues/404
[#406]: https://github.com/DataDog/puppet-datadog-agent/issues/406
[#408]: https://github.com/DataDog/puppet-datadog-agent/issues/408
[#411]: https://github.com/DataDog/puppet-datadog-agent/issues/411
[#412]: https://github.com/DataDog/puppet-datadog-agent/issues/412
[#417]: https://github.com/DataDog/puppet-datadog-agent/issues/417
[#418]: https://github.com/DataDog/puppet-datadog-agent/issues/418
[#420]: https://github.com/DataDog/puppet-datadog-agent/issues/420
[#424]: https://github.com/DataDog/puppet-datadog-agent/issues/424
[#426]: https://github.com/DataDog/puppet-datadog-agent/issues/426
[#427]: https://github.com/DataDog/puppet-datadog-agent/issues/427
[#431]: https://github.com/DataDog/puppet-datadog-agent/issues/431
[#433]: https://github.com/DataDog/puppet-datadog-agent/issues/433
[#437]: https://github.com/DataDog/puppet-datadog-agent/issues/437
[#438]: https://github.com/DataDog/puppet-datadog-agent/issues/438
[#439]: https://github.com/DataDog/puppet-datadog-agent/issues/439
[#443]: https://github.com/DataDog/puppet-datadog-agent/issues/443
[#444]: https://github.com/DataDog/puppet-datadog-agent/issues/444
[#445]: https://github.com/DataDog/puppet-datadog-agent/issues/445
[#446]: https://github.com/DataDog/puppet-datadog-agent/issues/446
[#449]: https://github.com/DataDog/puppet-datadog-agent/issues/449
[#455]: https://github.com/DataDog/puppet-datadog-agent/issues/455
[#462]: https://github.com/DataDog/puppet-datadog-agent/issues/462
[#463]: https://github.com/DataDog/puppet-datadog-agent/issues/463
[#464]: https://github.com/DataDog/puppet-datadog-agent/issues/464
[#466]: https://github.com/DataDog/puppet-datadog-agent/issues/466
[#468]: https://github.com/DataDog/puppet-datadog-agent/issues/468
[#470]: https://github.com/DataDog/puppet-datadog-agent/issues/470
[#471]: https://github.com/DataDog/puppet-datadog-agent/issues/471
[#472]: https://github.com/DataDog/puppet-datadog-agent/issues/472
[#473]: https://github.com/DataDog/puppet-datadog-agent/issues/473
[#475]: https://github.com/DataDog/puppet-datadog-agent/issues/475
[#481]: https://github.com/DataDog/puppet-datadog-agent/issues/481
[#482]: https://github.com/DataDog/puppet-datadog-agent/issues/482
[#484]: https://github.com/DataDog/puppet-datadog-agent/issues/484
[#485]: https://github.com/DataDog/puppet-datadog-agent/issues/485
[#486]: https://github.com/DataDog/puppet-datadog-agent/issues/486
[#487]: https://github.com/DataDog/puppet-datadog-agent/issues/487
[#490]: https://github.com/DataDog/puppet-datadog-agent/issues/490
[#492]: https://github.com/DataDog/puppet-datadog-agent/issues/492
[#493]: https://github.com/DataDog/puppet-datadog-agent/issues/493
[#496]: https://github.com/DataDog/puppet-datadog-agent/issues/496
[#498]: https://github.com/DataDog/puppet-datadog-agent/issues/498
[#501]: https://github.com/DataDog/puppet-datadog-agent/issues/501
[#502]: https://github.com/DataDog/puppet-datadog-agent/issues/502
[#503]: https://github.com/DataDog/puppet-datadog-agent/issues/503
[#504]: https://github.com/DataDog/puppet-datadog-agent/issues/504
[#506]: https://github.com/DataDog/puppet-datadog-agent/issues/506
[#507]: https://github.com/DataDog/puppet-datadog-agent/issues/507
[#508]: https://github.com/DataDog/puppet-datadog-agent/issues/508
[#513]: https://github.com/DataDog/puppet-datadog-agent/issues/513
[#514]: https://github.com/DataDog/puppet-datadog-agent/issues/514
[#515]: https://github.com/DataDog/puppet-datadog-agent/issues/515
[#516]: https://github.com/DataDog/puppet-datadog-agent/issues/516
[#519]: https://github.com/DataDog/puppet-datadog-agent/issues/519
[#520]: https://github.com/DataDog/puppet-datadog-agent/issues/520
[#521]: https://github.com/DataDog/puppet-datadog-agent/issues/521
[#524]: https://github.com/DataDog/puppet-datadog-agent/issues/524
[#525]: https://github.com/DataDog/puppet-datadog-agent/issues/525
[#527]: https://github.com/DataDog/puppet-datadog-agent/issues/527
[#528]: https://github.com/DataDog/puppet-datadog-agent/issues/528
[#533]: https://github.com/DataDog/puppet-datadog-agent/issues/533
[#534]: https://github.com/DataDog/puppet-datadog-agent/issues/534
[#537]: https://github.com/DataDog/puppet-datadog-agent/issues/537
[#544]: https://github.com/DataDog/puppet-datadog-agent/issues/544
[#545]: https://github.com/DataDog/puppet-datadog-agent/issues/545
[#548]: https://github.com/DataDog/puppet-datadog-agent/issues/548
[#551]: https://github.com/DataDog/puppet-datadog-agent/issues/551
[#555]: https://github.com/DataDog/puppet-datadog-agent/issues/555
[#556]: https://github.com/DataDog/puppet-datadog-agent/issues/556
[#557]: https://github.com/DataDog/puppet-datadog-agent/issues/557
[#558]: https://github.com/DataDog/puppet-datadog-agent/issues/558
[@Aramack]: https://github.com/Aramack
[@BIAndrews]: https://github.com/BIAndrews
[@ColinHebert]: https://github.com/ColinHebert
[@ColinHerbert]: https://github.com/ColinHerbert
[@DDRBoxman]: https://github.com/DDRBoxman
[@IanCrouch]: https://github.com/IanCrouch
[@LeoCavaille]: https://github.com/LeoCavaille
[@MartinDelta]: https://github.com/MartinDelta
[@NoodlesNZ]: https://github.com/NoodlesNZ
[@aaron-miller]: https://github.com/aaron-miller
[@aepod]: https://github.com/aepod
[@ajvb]: https://github.com/ajvb
[@alexfouche]: https://github.com/alexfouche
[@alexharv074]: https://github.com/alexharv074
[@alvin-huang]: https://github.com/alvin-huang
[@arkpoah]: https://github.com/arkpoah
[@b2jrock]: https://github.com/b2jrock
[@bflad]: https://github.com/bflad
[@binford2k]: https://github.com/binford2k
[@bit-herder]: https://github.com/bit-herder
[@bittner]: https://github.com/bittner
[@butangero]: https://github.com/butangero
[@cabrinha]: https://github.com/cabrinha
[@ckolos]: https://github.com/ckolos
[@com6056]: https://github.com/com6056
[@craigwatson]: https://github.com/craigwatson
[@cristianjuve]: https://github.com/cristianjuve
[@cwood]: https://github.com/cwood
[@dan70402]: https://github.com/dan70402
[@davejrt]: https://github.com/davejrt
[@davidgibbons]: https://github.com/davidgibbons
[@degemer]: https://github.com/degemer
[@denmat]: https://github.com/denmat
[@diogokiss]: https://github.com/diogokiss
[@djova]: https://github.com/djova
[@dorg-kanderson]: https://github.com/dorg-kanderson
[@dpricha89]: https://github.com/dpricha89
[@dschaaff]: https://github.com/dschaaff
[@dzinek]: https://github.com/dzinek
[@eddmann]: https://github.com/eddmann
[@evansj]: https://github.com/evansj
[@ewansteele]: https://github.com/ewansteele
[@ffleming]: https://github.com/ffleming
[@flyinprogrammer]: https://github.com/flyinprogrammer
[@fr3nd]: https://github.com/fr3nd
[@fwelschen]: https://github.com/fwelschen
[@fzwart]: https://github.com/fzwart
[@generica]: https://github.com/generica
[@gotyaio]: https://github.com/gotyaio
[@grubernaut]: https://github.com/grubernaut
[@jacobbednarz]: https://github.com/jacobbednarz
[@jadams-av]: https://github.com/jadams-av
[@jameynelson]: https://github.com/jameynelson
[@jangie]: https://github.com/jangie
[@jcarr-sailthru]: https://github.com/jcarr-sailthru
[@jdavisp3]: https://github.com/jdavisp3
[@jensendw]: https://github.com/jensendw
[@jfrost]: https://github.com/jfrost
[@jniesen]: https://github.com/jniesen
[@jubagarie]: https://github.com/jubagarie
[@kevin-bowers]: https://github.com/kevin-bowers
[@kitchen]: https://github.com/kitchen
[@lowkeyshift]: https://github.com/lowkeyshift
[@mcasper]: https://github.com/mcasper
[@milescrabill]: https://github.com/milescrabill
[@mraylu]: https://github.com/mraylu
[@mrunkel-ut]: https://github.com/mrunkel-ut
[@mtougeron]: https://github.com/mtougeron
[@npaufler]: https://github.com/npaufler
[@o0oxid]: https://github.com/o0oxid
[@obi11235]: https://github.com/obi11235
[@obowersa]: https://github.com/obowersa
[@oshmyrko]: https://github.com/oshmyrko
[@pabrahamsson]: https://github.com/pabrahamsson
[@paulhamby]: https://github.com/paulhamby
[@pid1]: https://github.com/pid1
[@pulkitsethi]: https://github.com/pulkitsethi
[@rmrf-run]: https://github.com/rmrf-run
[@rooprob]: https://github.com/rooprob
[@rothgar]: https://github.com/rothgar
[@rtyler]: https://github.com/rtyler
[@sambanks]: https://github.com/sambanks
[@samueljamesmarshall]: https://github.com/samueljamesmarshall
[@scottgeary]: https://github.com/scottgeary
[@sethcleveland]: https://github.com/sethcleveland
[@siebrand]: https://github.com/siebrand
[@skiedude]: https://github.com/skiedude
[@spectralblu]: https://github.com/spectralblu
[@stamak]: https://github.com/stamak
[@stantona]: https://github.com/stantona
[@swwolf]: https://github.com/swwolf
[@szponek]: https://github.com/szponek
[@tdm4]: https://github.com/tdm4
[@teintuc]: https://github.com/teintuc
[@tommoyangn]: https://github.com/tommoyangn
[@turnopil]: https://github.com/turnopil
[@tuxinaut]: https://github.com/tuxinaut
[@yrcjaya]: https://github.com/yrcjaya
[@zabacad]: https://github.com/zabacad
[@zickzackv]: https://github.com/zickzackv
[@zoom-kris-anderson]: https://github.com/zoom-kris-anderson
