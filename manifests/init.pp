# Class: datadog_agent
#
# This class contains the agent installation mechanism for the Datadog module
#
# Parameters:
#   $dd_url:
#       The host of the Datadog intake server to send agent data to.
#       Defaults to https://app.datadoghq.com.
#   $host:
#       Your hostname to see in Datadog. Defaults with Datadog hostname detection.
#   $api_key:
#       Your DataDog API Key. Please replace with your key value.
#   $tags
#       Optional array of tags.
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
#   $log_level
#       Set value of 'log_level' variable. Default is 'info' as in dd-agent.
#       Valid values here are: critical, debug, error, fatal, info, warn and warning.
#   $log_to_syslog
#       Set value of 'log_to_syslog' variable. Default is true -> yes as in dd-agent.
#       Valid values here are: true or false.
#   $use_mount
#       Allow overriding default of tracking disks by device path instead of mountpoint
#       Valid values here are: true or false.
#   $proxy_host
#       Set value of 'proxy_host' variable. Default is blank.
#   $proxy_port
#       Set value of 'proxy_port' variable. Default is blank.
#   $proxy_user
#       Set value of 'proxy_user' variable. Default is blank.
#   $proxy_password
#       Set value of 'proxy_password' variable. Default is blank.
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
  $tags = [],
  $facts_to_tags = [],
  $puppet_run_reports = false,
  $puppetmaster_user = 'puppet',
  $non_local_traffic = false,
  $log_level = 'info',
  $log_to_syslog = true,
  $service_ensure = 'running',
  $service_enable = true,
  $use_mount = false,
  $proxy_host = '',
  $proxy_port = '',
  $proxy_user = '',
  $proxy_password = '',
  $skip_ssl_validation = false,
  $collect_ec2_tags = false,
  $collect_instance_metadata = true,
  $recent_point_threshold = '',
  $listen_port = '',
  $graphite_listen_port = '',
  $additional_checksd = '',
  $use_curl_http_client = true,
  $bind_host = '',
  $use_pup = false,
  $pup_port = '',
  $pup_interface = '',
  $pup_url = '',
  $use_dogstatsd = false,
  $dogstatsd_port = '',
  $dogstatsd_target = '',
  $dogstatsd_interval = '',
  $dogstatsd_normalize = true,
  $statsd_forward_host = '',
  $statsd_forward_port = '',
  $device_blacklist_re = '',
  $ganglia_host = '',
  $ganglia_port = '',
  $custom_emitters = '',
  $collector_log_file = '',
  $forwarder_log_file = '',
  $dogstatsd_log_file = '',
  $pup_log_file = '',
) inherits datadog_agent::params {

  validate_string($dd_url)
  validate_string($host)
  validate_string($api_key)
  validate_array($tags)
  validate_array($facts_to_tags)
  validate_bool($puppet_run_reports)
  validate_string($puppetmaster_user)
  validate_bool($non_local_traffic)
  validate_bool($non_local_traffic)
  validate_bool($log_to_syslog)
  validate_string($log_level)
  validate_string($proxy_host)
  validate_string($proxy_port)
  validate_string($proxy_user)
  validate_string($proxy_password)
  validate_bool($skip_ssl_validation)
  validate_bool($collect_ec2_tags)
  validate_bool($collect_instance_metadata)
  validate_string($recent_point_threshold)
  validate_string($listen_port)
  validate_string($graphite_listen_port)
  validate_string($additional_checksd)
  validate_bool($use_curl_http_client)
  validate_string($bind_host)
  validate_bool($use_pup)
  validate_string($pup_port)
  validate_string($pup_interface)
  validate_string($pup_url)
  validate_bool($use_dogstatsd)
  validate_string($dogstatsd_port)
  validate_string($dogstatsd_target)
  validate_string($dogstatsd_interval)
  validate_bool($dogstatsd_normalize)
  validate_string($statsd_forward_host)
  validate_string($statsd_forward_port)
  validate_string($device_blacklist_re)
  validate_string($ganglia_host)
  validate_string($ganglia_port)
  validate_string($collector_log_file)
  validate_string($forwarder_log_file)
  validate_string($dogstatsd_log_file)
  validate_string($pup_log_file)

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
    'RedHat','CentOS','Fedora','Amazon','Scientific' : { include datadog_agent::redhat }
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
  file { '/etc/dd-agent/datadog.conf':
    ensure  => file,
    content => template('datadog_agent/datadog.conf.erb'),
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0640',
    notify  => Service[$datadog_agent::params::service_name],
    require => File['/etc/dd-agent'],
  }

  if $puppet_run_reports {
    class { 'datadog_agent::reports':
      api_key           => $api_key,
      puppetmaster_user => $puppetmaster_user,
    }
  }

}
