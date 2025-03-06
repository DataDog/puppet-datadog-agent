# Class: datadog_agent::integrations::postfix
#
# This class will install the necessary configuration for the Postfix integration
#
# See the sample postfix.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/postfix/datadog_checks/postfix/data/conf.yaml.example
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
  Array $queues              = ['active', 'deferred', 'incoming'],
  Array $tags                = [],
  Optional[Array] $instances = undef,
) inherits datadog_agent::params {
  require datadog_agent

  if !$instances and $directory {
    $_instances = [{
        'directory' => $directory,
        'queues'    => $queues,
        'tags'      => $tags
    }]
  } elsif !$instances {
    $_instances = []
  } else {
    $_instances = $instances
  }

  $dst_dir = "${datadog_agent::params::conf_dir}/postfix.d"

  file { $dst_dir:
    ensure  => directory,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_directory,
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
  $dst = "${dst_dir}/conf.yaml"

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/postfix.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
