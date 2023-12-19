# Class: datadog_agent::integrations::tcp_check
#
# This class will install the necessary config to hook the tcp_check in the agent
#
# Parameters:
#   @param check_name
#       (Required) - Name of the service.
#        This will be included as a tag: instance:<check_name>.
#
#   @param host
#       (Required) - Host to be checked.
#        This will be included as a tag: url:<host>:<port>.
#
#   @param port
#       (Required) - Port to be checked.
#        This will be included as a tag: url:<host>:<port>.
#
#   @param timeout
#       (Optional) - Timeout for the check. Defaults to 10 seconds.
#
#   @param threshold
#       (Optional) - Used in conjunction with window. An alert will
#        trigger if the check fails <threshold> times in <window> attempts.
#
#   @param window
#       (Optional) - Refer to threshold.
#
#   @param collect_response_time
#       (Optional) - Defaults to false. If this is not set to true, no
#       response time metric will be collected. If it is set to true, the
#       metric returned is network.tcp.response_time.
#
#   @param skip_event
#        The (optional) skip_event parameter will instruct the check to not
#        create any event to avoid duplicates with a server side service check.
#        This default to False.
#
#   @param tags
#       The (optional) tags to add to the check instance.
#
#   @param instances
#
#
# Sample Usage:
#
# Add a class for each check instance:
#
# class { 'datadog_agent::integrations::tcp_check':
#   check_name => 'localhost-ftp',
#   host       => 'ftp.example.com',
#   port       => '21',
# }
#
# class { 'datadog_agent::integrations::tcp_check':
#   check_name => 'localhost-ssh',
#   host       => '127.0.0.1',
#   port       => '22',
#   threshold  => 1,
#   window     => 1,
#   tags       => ['production', 'ssh access'],
# }
#
# class { 'datadog_agent::integrations::tcp_check':
#   name                  => 'localhost-web-response',
#   host                  => '127.0.0.1',
#   port                  => '80',
#   timeout               => '8',
#   threshold             => 1,
#   window                => 1,
#   collect_response_time => 1,
#   skip_event            => 1,
#   tags                  => ['production', 'webserver response time'],
# }
#
# Add multiple instances in one class declaration:
#
#  class { 'datadog_agent::integrations::tcp_check':
#        instances => [{
#          'check_name' => 'www.example.com-http',
#          'host'       => 'www.example.com',
#          'port'       => '80',
#        },
#        {
#          'check_name' => 'www.example.com-https',
#          'host'       => 'www.example.com',
#          'port'       => '443',
#        }]
#     }
#
class datadog_agent::integrations::tcp_check (
  Optional[String] $check_name             = undef,
  Optional[String] $host                   = undef,
  Optional[Variant[String, Integer]] $port = undef,
  Integer $timeout                         = 10,
  Optional[Integer] $threshold             = undef,
  Optional[Integer] $window                = undef,
  Optional[Integer] $collect_response_time = undef,
  Optional[Integer] $skip_event            = undef,
  Array $tags                              = [],
  Optional[Array] $instances               = undef,
) inherits datadog_agent::params {
  require datadog_agent

  if !$instances and $host {
    $_instances = [{
        'check_name'            => $check_name,
        'host'                  => $host,
        'port'                  => $port,
        'timeout'               => $timeout,
        'threshold'             => $threshold,
        'window'                => $window,
        'collect_response_time' => $collect_response_time,
        'skip_event'            => $skip_event,
        'tags'                  => $tags,
    }]
  } elsif !$instances {
    $_instances = []
  } else {
    $_instances = $instances
  }

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/tcp_check.yaml"
  if versioncmp($datadog_agent::_agent_major_version, '5') > 0 {
    $dst_dir = "${datadog_agent::params::conf_dir}/tcp_check.d"
    file { $legacy_dst:
      ensure => 'absent',
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name],
    }
    $dst = "${dst_dir}/conf.yaml"
  } else {
    $dst = $legacy_dst
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/tcp_check.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
