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
  $directory              = '/var/spool/postfix',
  $queues                 = [ 'active', 'deferred', 'incoming' ],
  $tags                   = [],
  $instances = undef,
) inherits datadog_agent::params {
  include datadog_agent

  validate_string($directory)
  validate_array($queues)
  validate_array($tags)

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

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/postfix.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/postfix.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/postfix.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
