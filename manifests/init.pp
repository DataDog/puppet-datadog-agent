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
#   $collect_instance_metadata
#       The Agent will try to collect instance metadata for EC2 and GCE instances.
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
#   $collect_ec2_tas
#       Presents custom EC2 tags as agent tags to datadog
#       Boolean. Default: False
#   $collect_instance_metadata
#       Enables the agent to try and gather instance metadata on EC2/GCE
#       Boolean. Default: true
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
#       Boolean. Default: false
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
#
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
  $hiera_tags = false,
  $facts_to_tags = [],
  $puppet_run_reports = false,
  $puppetmaster_user = 'puppet',
  $non_local_traffic = false,
  $dogstreams = [],
  $log_level = 'info',
  $log_to_syslog = true,
  $service_ensure = 'running',
  $service_enable = true,
  $manage_repo = true,
  $hostname_extraction_regex = nil,
  $dogstatsd_port = 8125,
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
  $use_dogstatsd = false,
  $dogstatsd_target = '',
  $dogstatsd_interval = '',
  $dogstatsd_normalize = true,
  $device_blacklist_re = '',
  $custom_emitters = '',
  $collector_log_file = '',
  $forwarder_log_file = '',
  $dogstatsd_log_file = '',
  $pup_log_file = '',
  $syslog_host  = '',
  $syslog_port  = '',
) inherits datadog_agent::params {

  validate_string($dd_url)
  validate_string($host)
  validate_string($api_key)
  validate_array($tags)
  validate_bool($hiera_tags)
  validate_array($dogstreams)
  validate_array($facts_to_tags)
  validate_bool($puppet_run_reports)
  validate_string($puppetmaster_user)
  validate_bool($non_local_traffic)
  validate_bool($log_to_syslog)
  validate_bool($manage_repo)
  validate_string($log_level)
  validate_integer($dogstatsd_port)
  validate_string($statsd_histogram_percentiles)
  validate_string($statsd_forward_port)
  validate_string($proxy_host)
  validate_string($proxy_port)
  validate_string($proxy_user)
  validate_string($proxy_password)
  validate_string($graphite_listen_port)
  validate_string($extra_template)
  validate_string($ganglia_host)
  validate_integer($ganglia_port)
  validate_bool($skip_ssl_validation)
  validate_bool($skip_apt_key_trusting)
  validate_bool($use_curl_http_client)
  validate_bool($collect_ec2_tags)
  validate_bool($collect_instance_metadata)
  validate_string($recent_point_threshold)
  validate_string($listen_port)
  validate_string($additional_checksd)
  validate_string($bind_host)
  validate_bool($use_pup)
  validate_string($pup_port)
  validate_string($pup_interface)
  validate_string($pup_url)
  validate_bool($use_dogstatsd)
  validate_string($dogstatsd_target)
  validate_string($dogstatsd_interval)
  validate_bool($dogstatsd_normalize)
  validate_string($statsd_forward_host)
  validate_string($device_blacklist_re)
  validate_string($custom_emitters)
  validate_string($collector_log_file)
  validate_string($forwarder_log_file)
  validate_string($dogstatsd_log_file)
  validate_string($pup_log_file)
  validate_string($syslog_host)
  validate_string($syslog_port)

  if $hiera_tags {
    $local_tags = hiera_array('datadog_agent::tags')
  } else {
    $local_tags = $tags
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
    'Ubuntu','Debian' : { include datadog_agent::ubuntu }
    'RedHat','CentOS','Fedora','Amazon','Scientific' : {
      class { 'datadog_agent::redhat':
        manage_repo => $manage_repo,
      }
    }
    default: { fail("Class[datadog_agent]: Unsupported operatingsystem: ${::operatingsystem}") }
  }

  file { '/etc/dd-agent':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['datadog-agent'],
  }

  # main agent config file
  # content
  if ($extra_template != '') {
    $agent_conf_content = template(
      'datadog_agent/datadog.conf.erb',
      $extra_template
    )
  } else {
    $agent_conf_content = template('datadog_agent/datadog.conf.erb')
  }
  file { '/etc/dd-agent/datadog.conf':
    ensure  => file,
    content => $agent_conf_content,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0640',
    notify  => Service[$datadog_agent::params::service_name],
    require => File['/etc/dd-agent'],
  }

  if $puppet_run_reports {
    class { 'datadog_agent::reports':
      api_key                   => $api_key,
      puppetmaster_user         => $puppetmaster_user,
      hostname_extraction_regex => $hostname_extraction_regex,
    }
  }
}
