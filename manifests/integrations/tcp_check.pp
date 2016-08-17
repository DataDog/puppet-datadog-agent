# Class: datadog_agent::integrations::tcp_check
#
# This class will install the necessary config to hook the tcp_check in the agent
#
# Parameters:
#   name
#   host
#   port
#   timeout
#
#   threshold
#   window
#       The (optional) window and threshold parameters allow you to trigger
#       alerts only if the check fails x times within the last y attempts
#       where x is the threshold and y is the window.
#
#   collect_response_time
#       The (optional) collect_response_time parameter will instruct the
#       check to create a metric 'network.tcp.response_time', tagged with
#       the url, reporting the response time in seconds.
#
#
#   tags
#
# Sample Usage:
#
# class { 'datadog_agent::integrations::tcp_check':
#   name => 'google',
#   host => 'www.google.com',
#   port => 9000,
# }
#
#
# class { 'datadog_agent::integrations::tcp_check':
#   name                  => 'api.hostname.com'
#   host                  => 'api.hostname.com',
#   port                  => 9000
#   timeout               => 5,
#   threshold             => 1,
#   window                => 1,
#   include_content       => true,
#   collect_response_time => true,
#   tags                  => 'production',
# }
#
#
class datadog_agent::integrations::tcp_check (
  $check_name = $title,
  $host       = undef,
  $port       = undef,
  $timeout    = 1,
  $threshold  = 5,
  $window     = undef,
  $collect_response_time = true,
  $tags       = [],
  $instances  = undef,
) inherits datadog_agent::params {
  include datadog_agent

  if !$instances and $host {
    $_instances = [{
      'name'                  => $check_name,
      'host'                  => $host,
      'port'                  => $port,
      'timeout'               => $timeout,
      'threshold'             => $threshold,
      'window'                => $window,
      'collect_response_time' => $collect_response_time,
      'tags'                  => $tags,
    }]
  } elsif !$instances{
    $_instances = []
  } else {
    $_instances = $instances
  }

  file { "${datadog_agent::params::conf_dir}/tcp_check.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/tcp_check.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
