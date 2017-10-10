# Class: datadog_agent::integrations::tcp_check
#
# This class will install the necessary config to hook the tcp_check in the agent
#
# Parameters:
#   name
#       (Required) - Name of the service. 
#        This will be included as a tag: instance:<name>.
#
#   host
#       (Required) - Host to be checked. 
#        This will be included as a tag: url:<host>:<port>.
#
#   port
#       (Required) - Port to be checked. 
#        This will be included as a tag: url:<host>:<port>.
#
#   timeout
#       (Optional) - Timeout for the check. Defaults to 10 seconds.
#
#   threshold
#       (Optional) - Used in conjunction with window. An alert will 
#        trigger if the check fails <threshold> times in <window> attempts.
#
#   window
#       (Optional) - Refer to threshold.
#
#   collect_response_time
#       (Optional) - Defaults to false. If this is not set to true, no 
#       response time metric will be collected. If it is set to true, the 
#       metric returned is network.tcp.response_time. 
#
#   skip_event
#        The (optional) skip_event parameter will instruct the check to not
#        create any event to avoid duplicates with a server side service check.
#        This default to False.
#
#   tags
#       The (optional) tags to add to the check instance.
#
# Sample Usage:
#
# Add a class for each check instance:
#
# class { 'datadog_agent::integrations::tcp_check':
#   name  => 'localhost-ftp',
#   host       => 'ftp.example.com',
#   port       => '21',
# }
#
# class { 'datadog_agent::integrations::tcp_check':
#   name  => 'localhost-ssh',
#   host       => '127.0.0.1',
#   port       => '22',
#   threshold             => 1,
#   window                => 1,
#   tags     => ['production', 'ssh access'],
# }
#
# class { 'datadog_agent::integrations::tcp_check':
#   name  => 'localhost-web-response',
#   host       => '127.0.0.1',
#   port       => '80',
#   timeout    => '8',
#   threshold             => 1,
#   window                => 1,
#   collect_response_time => 1,
#   skip_event            => 1,
#   tags     => ['production', 'webserver response time'],
# }
#
# Add multiple instances in one class declaration:
#
#  class { 'datadog_agent::integrations::tcp_check':
#        instances => [{
#          'name'  => 'www.example.com-http',
#          'host'  => 'www.example.com',
#          'port'       => '80',
#        },
#        {
#          'name'  => 'www.example.com-https',
#          'host'  => 'www.example.com',
#          'port'       => '443',
#        }]
#     }


class datadog_agent::integrations::tcp_check (
  $check_name      = undef,
  $host      = undef,
  $port      = undef,
  $timeout   = 10,
  $threshold = undef,
  $window    = undef,
  $collect_response_time = undef,
  $skip_event = undef,
  $tags      = [],
  $instances  = undef,
) inherits datadog_agent::params {
  include datadog_agent

  if !$instances and $host {
    $_instances = [{
      'check_name'                   => $check_name,
      'host'                         => $host,
      'port'                         => $port,
      'timeout'                      => $timeout,
      'threshold'                    => $threshold,
      'window'                       => $window,
      'collect_response_time'        => $collect_response_time,
      'skip_event'                   => $skip_event,
      'tags'                         => $tags,
    }]
  } elsif !$instances{
    $_instances = []
  } else {
    $_instances = $instances
  }

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/tcp_check.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/tcp_check.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/tcp_check.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
