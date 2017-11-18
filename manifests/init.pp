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
#       String. Default: empty
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
  $collect_ec2_tags = false,
  $collect_instance_metadata = true,
  $tags = [],
  $integrations = {},
  $hiera_integrations = false,
  $hiera_tags = false,
  $facts_to_tags = [],
  $puppet_run_reports = false,
  $puppet_gem_provider = 'puppetserver_gem',
  $puppetmaster_user = $settings::user,
  $non_local_traffic = false,
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
  $agent6_enable = $datadog_agent::params::agent6_enable,
  $conf_dir = $datadog_agent::params::conf_dir,
  $conf6_dir = $datadog_agent::params::conf6_dir,
  $conf_dir_purge = $datadog_agent::params::conf_dir_purge,
  $service_name = $datadog_agent::params::service_name,
  $package_name = $datadog_agent::params::package_name,
  $dd_user = $datadog_agent::params::dd_user,
  $dd_group = $datadog_agent::params::dd_group,
  $apm_enabled = false,
  $apm_env = '',
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

  validate_string($dd_url)
  validate_string($host)
  validate_string($api_key)
  validate_array($tags)
  validate_bool($hiera_tags)
  validate_array($dogstreams)
  validate_array($facts_to_tags)
  validate_bool($puppet_run_reports)
  validate_string($puppet_gem_provider)
  validate_string($puppetmaster_user)
  validate_bool($non_local_traffic)
  validate_bool($log_to_syslog)
  validate_bool($manage_repo)
  validate_string($log_level)
  validate_re($_dogstatsd_port, '^\d*$')
  validate_string($statsd_histogram_percentiles)
  validate_re($_statsd_forward_port, '^\d*$')
  validate_string($proxy_host)
  validate_re($_proxy_port, '^\d*$')
  validate_string($proxy_user)
  validate_string($proxy_password)
  validate_re($_graphite_listen_port, '^\d*$')
  validate_string($extra_template)
  validate_string($ganglia_host)
  validate_integer($ganglia_port)
  validate_bool($skip_ssl_validation)
  validate_bool($skip_apt_key_trusting)
  validate_bool($use_curl_http_client)
  validate_bool($collect_ec2_tags)
  validate_bool($collect_instance_metadata)
  validate_string($recent_point_threshold)
  validate_re($_listen_port, '^\d*$')
  validate_string($additional_checksd)
  validate_string($bind_host)
  validate_bool($use_pup)
  validate_re($_pup_port, '^\d*$')
  validate_string($pup_interface)
  validate_string($pup_url)
  validate_bool($use_dogstatsd)
  validate_string($dogstatsd_target)
  validate_string($dogstatsd_interval)
  validate_bool($dogstatsd_normalize)
  validate_string($statsd_forward_host)
  validate_string($device_blacklist_re)
  validate_string($custom_emitters)
  validate_string($agent6_log_file)
  validate_string($collector_log_file)
  validate_string($forwarder_log_file)
  validate_string($dogstatsd_log_file)
  validate_string($pup_log_file)
  validate_string($syslog_host)
  validate_re($_syslog_port, '^\d*$')
  validate_string($service_discovery_backend)
  validate_string($sd_config_backend)
  validate_string($sd_backend_host)
  validate_integer($sd_backend_port)
  validate_string($sd_template_dir)
  validate_bool($sd_jmx_enable)
  validate_string($consul_token)
  validate_bool($apm_enabled)
  validate_bool($agent6_enable)
  validate_string($apm_env)

  if $hiera_tags {
    $local_tags = hiera_array('datadog_agent::tags', [])
  } else {
    $local_tags = $tags
  }

  if $hiera_integrations {
    $local_integrations = hiera_hash('datadog_agent::integrations', {})
  } else {
    $local_integrations = $integrations
  }

  datadog_agent::tag{$local_tags: }
  datadog_agent::tag{$facts_to_tags:
    lookup_fact => true,
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
      if !$agent6_enable {
        include datadog_agent::ubuntu
      } else {
        include datadog_agent::ubuntu::agent6
      }
    }
    'RedHat','CentOS','Fedora','Amazon','Scientific' : {
      if !$agent6_enable {
        class { 'datadog_agent::redhat':
          manage_repo => $manage_repo,
        }
      } else {
        class { 'datadog_agent::redhat::agent6':
          manage_repo => $manage_repo,
        }
      }
    }
    default: { fail("Class[datadog_agent]: Unsupported operatingsystem: ${::operatingsystem}") }
  }

  # required by reports even in agent5 scenario
  file { '/etc/datadog-agent':
    ensure  => directory,
    owner   => $dd_user,
    group   => $dd_group,
    mode    => '0755',
    require => Package['datadog-agent'],
  }


  if !$agent6_enable {
    file { '/etc/dd-agent':
      ensure  => directory,
      owner   => $dd_user,
      group   => $dd_group,
      mode    => '0755',
      require => Package['datadog-agent'],
    }

    file { $conf_dir:
      ensure  => directory,
      purge   => $conf_dir_purge,
      recurse => true,
      force   => $conf_dir_purge,
      owner   => $dd_user,
      group   => $dd_group,
      notify  => Service['datadog-agent']
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
      $apm_footer_order = '07'
    } else {
      $apm_footer_order = '06'
    }

    concat::fragment{ 'datadog apm footer':
      target  => '/etc/dd-agent/datadog.conf',
      content => template('datadog_agent/datadog_apm_footer.conf.erb'),
      order   => $apm_footer_order,
    }
  } else {

    file { $conf6_dir:
      ensure  => directory,
      purge   => $conf_dir_purge,
      recurse => true,
      force   => $conf_dir_purge,
      owner   => $dd_user,
      group   => $dd_group,
      notify  => Service['datadog-agent']
    }

    $agent_config = {
      'api_key' => $api_key,
      'dd_url' => $dd_url,
      'cmd_port' => 5001,
      'conf_path' => $datadog_agent::params::conf6_dir,
      'enable_metadata_collection' => $collect_instance_metadata,
      'dogstatsd_port' => $dogstatsd_port,
      'dogstatsd_socket' => $dogstatsd_socket,
      'dogstatsd_non_local_traffic' => $non_local_traffic,
      'log_file' => $agent6_log_file,
      'log_level' => $log_level,
    }

    file { '/etc/datadog-agent/datadog.yaml':
      owner   => 'dd-agent',
      group   => 'dd-agent',
      mode    => '0640',
      content => template('datadog_agent/datadog6.yaml.erb'),
      notify  => Service[$datadog_agent::params::service_name],
      require => File['/etc/datadog-agent'],
    }
  }


  if $puppet_run_reports {
    class { 'datadog_agent::reports':
      api_key                   => $api_key,
      puppet_gem_provider       => $puppet_gem_provider,
      puppetmaster_user         => $puppetmaster_user,
      dogapi_version            => $datadog_agent::params::dogapi_version,
      hostname_extraction_regex => $hostname_extraction_regex,
    }
  }

  create_resources('datadog_agent::integration', $local_integrations)
}
