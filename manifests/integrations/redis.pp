# Class: datadog::integrations::redis
#
# This class will install the necessary configuration for the redis integration
#
# Parameters:
#   $host:
#       The host redis is running on
#   $password
#       The redis password (optional)
#   $port
#       The redis port
#   $tags
#       Optional array of tags
#   $keys
#       Optional array of keys to check length
#
# Sample Usage:
#
#  class { 'datadog::integrations::redis' :
#    host => 'localhost',
#  }
#
#
class datadog::integrations::redis(
  $host = 'localhost',
  $password = '',
  $port = 6379,
  $tags = [],
  $keys = [],
) inherits datadog::params {

  validate_re( $port, '^\d+$' )
  validate_array( $tags )
  validate_array( $keys )

  package { $redis_int_package :
    ensure => installed,
  }

  file { "${conf_dir}/redisdb.yaml":
    ensure  => file,
    owner   => $datadog::dd_user,
    group   => $datadog::dd_group,
    mode    => 0600,
    content => template('datadog/agent-conf.d/redisdb.yaml.erb'),
    require => Package[$redis_int_package],
    notify  => Service[$service_name]
  }
}
