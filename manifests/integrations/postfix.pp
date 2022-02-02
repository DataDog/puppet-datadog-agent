# Class: datadog_agent::integrations::postfix
#
# This class will install the necessary configuration for the Postfix integration
#
# Parameters:
#   $url:
#       url used to connect to the Postfixd instance
#   $port:
#   $tags
#       Optional array of tags
#
# Sample Usage:
#
# include 'datadog_agent::integrations::postfix'
#
# OR
#
# class { 'datadog_agent::integrations::postfix':
#   directory => '/var/spool/postfix-2'
# }
#
#
# Sample Usage (Instance):
#  class { 'datadog_agent::integrations::postfix' :
#    instances => [{
#      directory => '/var/spool/postfix-2',
#      queues    => [ 'active', 'deferred' ]
#    }]
#  }
#
class datadog_agent::integrations::postfix (
  String $directory          = '/var/spool/postfix',
  Array $queues              = [ 'active', 'deferred', 'incoming' ],
  Optional[Array] $tags      = [],
  Optional[Array] $instances = undef,
) inherits datadog_agent::params {
  require ::datadog_agent

  if !$instances and $directory {
    $_instances = [{
      'directory'   => $directory,
      'queues'      => $queues,
      'tags'        => $tags
    }]
  } elsif !$instances{
    $_instances = []
  } else {
    $_instances = $instances
  }

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/postfix.yaml"
  if $::datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/postfix.d"
    file { $legacy_dst:
      ensure => 'absent'
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name]
    }
    $dst = "${dst_dir}/conf.yaml"
  } else {
    $dst = $legacy_dst
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/postfix.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
