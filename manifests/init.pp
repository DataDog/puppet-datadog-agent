# Class: datadog_agent
#
# This class contains the agent installation mechanism for the Datadog module
#
# Parameters:
#   $dd_url:
#       The host of the Datadog intake server to send agent data to.
#       Defaults to https://app.datadoghq.com.
#   $host:
#   $api_key:
#       Your DataDog API Key. Please replace with your key value.
#   $collect_ec2_tags
#       Collect AWS EC2 custom tags as agent tags.
#       Boolean. Default: false
#   $collect_instance_metadata
#       The Agent will try to collect instance metadata for EC2 and GCE instances.
#       Boolean. Default: true
#   $tags
#       Optional array of tags.
#   $hiera_tags
#       Boolean to grab tags from hiera to allow merging
#   $facts_to_tags
#       Optional array of facts' names that you can use to define tags following
#       the scheme: "fact_name:fact_value".
#   $puppet_run_reports
#       Will send results from your puppet agent runs back to the datadog service.
#   $puppetmaster_user
#       Will chown the api key used by the report processor to this user.
#       Defaults to the user the puppetmaster is configured to run as.
#   $non_local_traffic
#       Enable you to use the agent as a proxy. Defaults to false.
#       See https://github.com/DataDog/dd-agent/wiki/Proxy-Configuration
#   $dogstreams
#       Optional array of logs to parse and custom parsers to use.
#       See https://github.com/DataDog/dd-agent/blob/ed5e698/datadog.conf.example#L149-L178
#   $log_level
#       Set value of 'log_level' variable. Default is 'info' as in dd-agent.
#       Valid values here are: critical, debug, error, fatal, info, warn and warning.
#   $hostname_extraction_regex
#       Completely optional.
#       Instead of reporting the puppet nodename, use this regex to extract the named
#       'hostname' captured group to report the run in Datadog.
#       ex.: '^(?<hostname>.*\.datadoghq\.com)(\.i-\w{8}\..*)?$'
#   $log_to_syslog
#       Set value of 'log_to_syslog' variable. Default is true -> yes as in dd-agent.
#       Valid values here are: true or false.
#   $dogstatsd_port
#       Set value of the 'dogstatsd_port' variable. Defaultis 8125.
#   $statsd_forward_host
#       Set the value of the statsd_forward_host varable. Used to forward all
#       statsd metrics to another host.
#   $statsd_forward_port
#       Set the value of the statsd_forward_port varable. Used to forward all
#       statsd metrics to another host.
#   $manage_repo
#       Boolean to indicate whether this module should attempt to manage
#       the package repo. Default true.
#   $proxy_host
#       Set value of 'proxy_host' variable. Default is blank.
#   $proxy_port
#       Set value of 'proxy_port' variable. Default is blank.
#   $proxy_user
#       Set value of 'proxy_user' variable. Default is blank.
#   $proxy_password
#       Set value of 'proxy_password' variable. Default is blank.
#   $graphite_listen_port
#       Set graphite listener port
#   $extra_template
#       Optional, append this extra template file at the end of
#       the default datadog.conf template
#   $skip_apt_key_trusting
#       Skip trusting the apt key. Default is false. Useful if you have a
#       separate way of adding keys.
#   $skip_ssl_validation
#       Skip SSL validation.
#   $use_curl_http_client
#       Uses the curl HTTP client for the forwarder
#   $recent_point_threshold
#       Sets the threshold for accepting points.
#   String. Default: empty (30 second intervals)
#   $listen_port
#       Change the port that the agent listens on
#       String. Default: empty (port 17123 in dd-agent)
#   $additional_checksd
#       Additional directory to look for datadog checks in
#       String. Default: empty
#   $bind_host
#       The loopback address the forwarder and Dogstatsd will bind.
#       String. Default: empty
#   $use_pup
#       Enables the local pup dashboard
#       Boolean. Default: false
#   $pup_port
#       Specifies the port to be used by pup. Must have use_pup set
#       String. Default: empty
#   $pup_interface
#       Specifies which interface pup will use. Must have use_pup set
#       String. Default: empty
#   $pup_url
#       Specifies the URL used to access pup. Must have use_pup set
#       String. Default: empty
#   $use_dogstatsd
#       Enables the dogstatsd server
#       Boolean. Default: true
#   $dogstatsd_socket
#       Specifies the socket file to be used by dogstatsd. Must have use_dogstatsd set
#       String. Default: empty
#   $dogstatsd_port
#       Specifies the port to be used by dogstatsd. Must have use_dogstatsd set
#       String. Default: empty
#   $dogstatsd_target
#       Change the target to be used by dogstatsd. Must have use_dogstatsd set
#       set
#       String. Default: empty
#   $dogstatsd_interval
#       Change the dogstatsd flush period. Must have use_dogstatsd set
#       String. Default: empty ( 10 second interval)
#   $dogstatsd_normalize
#       Enables 1 second nomralization. Must have use_dogstatsd set
#       Boolean. Default: true
#   $statsd_forward_host
#       Enables forwarding of statsd packetsto host. Must have use_dogstatsd set
#       String. Default: empty
#   $statsd_forward_port
#       Specifis port for $statsd_forward_host. Must have use_dogstatsd set
#       String. Default: empty
#   $device_blacklist_re
#       Specifies pattern for device blacklisting.
#       String. Default: empty
#   $ganglia_host
#       Specifies host where gmetad is running
#       String. Default: empty
#   $ganglia_port
#       Specifies port  for $ganglia_host
#       String. Default: empty
#   $dogstreams
#       Specifies port for list of logstreams/modules to be used.
#       String. Default: empty
#   $custom_emitters
#       Specifies a comma seperated list of non standard emitters to be used
#       String. Default: empty
#   $custom_emitters
#       Specifies a comma seperated list of non standard emitters to be used
#       String. Default: empty
#   $agent6_log_file
#       Specifies the log file location for the agent6
#       String. Default: empty
#   $collector_log_file
#       Specifies the log file location for the collector system
#       String. Default: empty
#   $forwarder_log_file
#       Specifies the log file location for the forwarder system
#       String. Default: empty
#   $dogstatsd
#       Specifies the log file location for the dogstatsd system
#       String. Default: empty
#   $pup_log_file
#       Specifies the log file location for the pup system
#       String. Default: empty
#   $apm_enabled
#       Boolean to enable or disable the trace agent
#       Boolean. Default: false
#   $apm_env
#       String defining the environment for the APM traces
#       String. Default: non
#   $apm_non_local_traffic
#       Accept non local apm traffic. Defaults to false.
#   $process_enabled
#       String to enable the process/container agent
#       Boolean. Default: false
#   $scrub_args
#       Boolean to enable or disable the process cmdline scrubbing by the process-agent
#       Boolean. Default: true
#   $custom_sensitive_words
#       Array to add more words to be used on the process cdmline scrubbing by the process-agent
#       Array. Default: []
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# include datadog_agent
#
# OR
#
# class { 'datadog_agent':
#     api_key   => 'your key',
#     tags      => ['env:production', 'linux'],
#     puppet_run_reports  => false,
#     puppetmaster_user   => puppet,
# }
#
#

class datadog_agent(
  $dd_url = 'https://app.datadoghq.com',
  $host = '',
  $api_key = 'your_API_key',
  $histogram_percentiles = '',
  $collect_ec2_tags = false,
  $collect_instance_metadata = true,
  $tags = [],
  $integrations = {},
  $hiera_integrations = false,
  $hiera_tags = false,
  $facts_to_tags = [],
  $puppet_run_reports = false,
  $puppetmaster_user = $settings::user,
  $non_local_traffic = true,
  $dogstreams = [],
  $log_level = 'info',
  $log_to_syslog = true,
  $service_ensure = 'running',
  $service_enable = true,
  $manage_repo = true,
  $hostname_extraction_regex = nil,
  $dogstatsd_port = 8125,
  $dogstatsd_socket = '',
  $statsd_forward_host = '',
  $statsd_forward_port = '',
  $statsd_histogram_percentiles = '0.95',
  $proxy_host = '',
  $proxy_port = '',
  $proxy_user = '',
  $proxy_password = '',
  $graphite_listen_port = '',
  $extra_template = '',
  $ganglia_host = '',
  $ganglia_port = 8651,
  $skip_ssl_validation = false,
  $skip_apt_key_trusting = false,
  $use_curl_http_client = false,
  $recent_point_threshold = '',
  $listen_port = '',
  $additional_checksd = '',
  $bind_host = '',
  $use_pup = false,
  $pup_port = '',
  $pup_interface = '',
  $pup_url = '',
  $use_dogstatsd = true,
  $dogstatsd_target = '',
  $dogstatsd_interval = '',
  $dogstatsd_normalize = true,
  $device_blacklist_re = '',
  $custom_emitters = '',
  $agent6_log_file = '/var/log/datadog/agent.log',
  $collector_log_file = '',
  $forwarder_log_file = '',
  $dogstatsd_log_file = '',
  $pup_log_file = '',
  $syslog_host  = '',
  $syslog_port  = '',
  $service_discovery_backend = '',
  $sd_config_backend = '',
  $sd_backend_host = '',
  $sd_backend_port = 0,
  $sd_template_dir = '',
  $sd_jmx_enable = false,
  $consul_token = '',
  $logs_enabled = true,
  $agent5_enable = $datadog_agent::params::agent5_enable,
  $conf_dir = $datadog_agent::params::conf_dir,
  $conf6_dir = $datadog_agent::params::conf6_dir,
  $conf_dir_purge = $datadog_agent::params::conf_dir_purge,
  $service_name = $datadog_agent::params::service_name,
  $package_name = $datadog_agent::params::package_name,
  $dd_user = $datadog_agent::params::dd_user,
  $dd_group = $datadog_agent::params::dd_group,
  $dd_groups = $datadog_agent::params::dd_groups,
  $apm_enabled = $datadog_agent::params::apm_default_enabled,
  $apm_env = 'none',
  $apm_non_local_traffic = true,
  $process_enabled = $datadog_agent::params::process_default_enabled,
  $scrub_args = $datadog_agent::params::process_default_scrub_args,
  $custom_sensitive_words = $datadog_agent::params::process_default_custom_words,
  Hash[String[1], Data] $agent6_extra_options = {},
  $agent5_repo_uri = $datadog_agent::params::agent5_default_repo,
  $agent6_repo_uri = $datadog_agent::params::agent6_default_repo,
  $apt_release = $datadog_agent::params::apt_default_release,
) inherits datadog_agent::params {

  # Allow ports to be passed as integers or strings.
  # lint:ignore:only_variable_string
  $_dogstatsd_port = "${dogstatsd_port}"
  $_statsd_forward_port = "${statsd_forward_port}"
  $_proxy_port = "${proxy_port}"
  $_graphite_listen_port = "${graphite_listen_port}"
  $_listen_port = "${listen_port}"
  $_pup_port = "${pup_port}"
  $_syslog_port = "${syslog_port}"
  # lint:endignore

  if $hiera_tags {
    $local_tags = lookup({ 'name' => 'datadog_agent::tags', 'default_value' => []})
  } else {
    $local_tags = $tags
  }

  if $hiera_integrations {
    $local_integrations = lookup({ 'name' => 'datadog_agent::integrations', 'default_value' => {}})
  } else {
    $local_integrations = $integrations
  }

  include datadog_agent::params
  case upcase($log_level) {
    'CRITICAL': { $_loglevel = 'CRITICAL' }
    'DEBUG':    { $_loglevel = 'DEBUG' }
    'ERROR':    { $_loglevel = 'ERROR' }
    'FATAL':    { $_loglevel = 'FATAL' }
    'INFO':     { $_loglevel = 'INFO' }
    'WARN':     { $_loglevel = 'WARN' }
    'WARNING':  { $_loglevel = 'WARNING' }
    default:    { $_loglevel = 'INFO' }
  }

  case $::operatingsystem {
    'Ubuntu','Debian' : {
      if $agent5_enable {
        class { 'datadog_agent::ubuntu::agent5':
          service_ensure        => $service_ensure,
          service_enable        => $service_enable,
          location              => $agent5_repo_uri,
          release               => $apt_release,
          skip_apt_key_trusting => $skip_apt_key_trusting,
        }
      } else {
        class { 'datadog_agent::ubuntu::agent6':
          service_ensure        => $service_ensure,
          service_enable        => $service_enable,
          location              => $agent6_repo_uri,
          release               => $apt_release,
          skip_apt_key_trusting => $skip_apt_key_trusting,
        }
      }
    }
    'RedHat','CentOS','Fedora','Amazon','Scientific' : {
      if $agent5_enable {
        class { 'datadog_agent::redhat::agent5':
          baseurl        => $agent5_repo_uri,
          manage_repo    => $manage_repo,
          service_ensure => $service_ensure,
          service_enable => $service_enable,
        }
      } else {
        class { 'datadog_agent::redhat::agent6':
          baseurl        => $agent6_repo_uri,
          manage_repo    => $manage_repo,
          service_ensure => $service_ensure,
          service_enable => $service_enable,
        }
      }
    }
    default: { fail("Class[datadog_agent]: Unsupported operatingsystem: ${::operatingsystem}") }
  }

  if ($dd_groups) {
    user { $dd_user:
      groups => $dd_groups,
      notify => Service[$datadog_agent::params::service_name],
    }
  }

  # required by reports even in agent5 scenario
  file { '/etc/datadog-agent':
    ensure  => directory,
    owner   => $dd_user,
    group   => $dd_group,
    mode    => '0755',
    require => Package[$datadog_agent::params::package_name],
  }

  if $agent5_enable {
    file { '/etc/dd-agent':
      ensure  => directory,
      owner   => $dd_user,
      group   => $dd_group,
      mode    => '0755',
      require => Package[$datadog_agent::params::package_name],
    }

    file { $conf_dir:
      ensure  => directory,
      purge   => $conf_dir_purge,
      recurse => true,
      force   => $conf_dir_purge,
      owner   => $dd_user,
      group   => $dd_group,
      notify  => Service[$datadog_agent::params::service_name]
    }

    concat {'/etc/dd-agent/datadog.conf':
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0640',
      notify  => Service[$datadog_agent::params::service_name],
      require => File['/etc/dd-agent'],
    }

    concat::fragment{ 'datadog header':
      target  => '/etc/dd-agent/datadog.conf',
      content => template('datadog_agent/datadog_header.conf.erb'),
      order   => '01',
    }

    concat::fragment{ 'datadog tags':
      target  => '/etc/dd-agent/datadog.conf',
      content => 'tags: ',
      order   => '02',
    }

    datadog_agent::tag5{$local_tags: }
    datadog_agent::tag5{$facts_to_tags:
      lookup_fact => true,
    }

    concat::fragment{ 'datadog footer':
      target  => '/etc/dd-agent/datadog.conf',
      content => template('datadog_agent/datadog_footer.conf.erb'),
      order   => '05',
    }

    if ($extra_template != '') {
      concat::fragment{ 'datadog extra_template footer':
        target  => '/etc/dd-agent/datadog.conf',
        content => template($extra_template),
        order   => '06',
      }
    }

    if ($apm_enabled == true) and ($apm_env != 'none') {
      concat::fragment{ 'datadog apm footer':
        target  => '/etc/dd-agent/datadog.conf',
        content => template('datadog_agent/datadog_apm_footer.conf.erb'),
        order   => '07',
      }
    }

    if ($process_enabled == true) {
      concat::fragment{ 'datadog process agent footer':
        target  => '/etc/dd-agent/datadog.conf',
        content => template('datadog_agent/datadog_process_footer.conf.erb'),
        order   => '08',
      }
    }
  } else {

    # lint:ignore:quoted_booleans
    $process_enabled_str = $process_enabled ? { true => 'true' , default => 'disabled' }
    # lint:endignore
    $base_extra_config = {
        'apm_config' => {
          'apm_enabled'           => $apm_enabled,
          'env'                   => $apm_env,
          'apm_non_local_traffic' => $apm_non_local_traffic
        },
        'process_config' => {
          'enabled' => $process_enabled_str,
          'scrub_args' => $scrub_args,
          'custom_sensitive_words' => $custom_sensitive_words,
        },
    }
    $extra_config = deep_merge($base_extra_config, $agent6_extra_options)

    file { $conf6_dir:
      ensure  => directory,
      purge   => $conf_dir_purge,
      recurse => true,
      force   => $conf_dir_purge,
      owner   => $dd_user,
      group   => $dd_group,
      notify  => Service[$datadog_agent::params::service_name]
    }

    $_agent_config = {
      'api_key' => $api_key,
      'dd_url' => $dd_url,
      'cmd_port' => 5001,
      'conf_path' => $datadog_agent::params::conf6_dir,
      'enable_metadata_collection' => $collect_instance_metadata,
      'dogstatsd_port' => $dogstatsd_port,
      'dogstatsd_socket' => $dogstatsd_socket,
      'dogstatsd_non_local_traffic' => $non_local_traffic,
      'logs_enabled' => true,
      'log_file' => $agent6_log_file,
      'log_level' => $log_level,
      'tags' => [],
    }

    $agent_config = deep_merge($_agent_config, $extra_config)

    file { '/etc/datadog-agent/datadog.yaml':
      owner   => 'dd-agent',
      group   => 'dd-agent',
      mode    => '0640',
      content => template('datadog_agent/datadog6.yaml.erb'),
      notify  => Service[$datadog_agent::params::service_name],
      require => File['/etc/datadog-agent'],
    }
  }

  if ( $ec2_tag_aws_autoscaling_groupname == 'dotcom-prod asg' ) {
    file {
      '/opt/datadog-agent/agent/dogstream/nginx.py':
        ensure => present,
        source  => 'puppet:///modules/datadog_agent/nginx.py',
        notify  => Service[$datadog_agent::params::service_name],
        require => Package['datadog-agent'];
    }
  }

  if ( $ec2_tag_aws_autoscaling_groupname == 'dotcom-staging asg' ) {
    file {
      '/opt/datadog-agent/agent/dogstream/nginx.py':
        ensure => present,
        source  => 'puppet:///modules/datadog_agent/nginx.py',
        notify  => Service[$datadog_agent::params::service_name],
        require => Package['datadog-agent'];
    }
  }

  if $puppet_run_reports {
    class { 'datadog_agent::reports':
      api_key                   => $api_key,
      dogapi_version            => $datadog_agent::params::dogapi_version,
      puppetmaster_user         => $puppetmaster_user,
      hostname_extraction_regex => $hostname_extraction_regex,
    }
  }
  
  create_resources('datadog_agent::integration', $local_integrations)

  file { '/etc/datadog-agent/conf.d/carabiner.d':
    ensure  => directory,
    purge   => $false,
    recurse => true,
    force   => $false,
    owner   => $dd_user,
    group   => $dd_group,
  }

  file { '/etc/datadog-agent/conf.d/carabiner.d/conf.yaml':
    ensure => present,
    source => 'puppet:///modules/datadog_agent/conf.yaml',
    notify  => Service[$datadog_agent::params::service_name],
    require => Package['datadog-agent'];
  }
}
