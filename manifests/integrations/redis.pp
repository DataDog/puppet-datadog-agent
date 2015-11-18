# Class: datadog_agent::integrations::redis
#
# This class will install the necessary configuration for the redis integration
#
# Parameters:
#   $host:
#       The host redis is running on
#   $password
#       The redis password (optional)
#   $port
#       The main redis port.
#   $ports
#       Array of redis ports: overrides port (optional)
#   $slowlog_max_len
#       The max length of the slow-query log (optional)
#   $tags
#       Optional array of tags
#   $keys
#       Optional array of keys to check length
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::redis' :
#    host => 'localhost',
#  }
#
#
class datadog_agent::integrations::redis(
  $host = 'localhost',
  $password = '',
  $port = 6379,
  $ports = undef,
  $slowlog_max_len = '',
  $tags = [],
  $keys = [],
  $warn_on_missing_keys = true,
) inherits datadog_agent::params {
  include datadog_agent

  validate_array($tags)
  validate_array($keys)
  validate_bool($warn_on_missing_keys)

  if $ports == undef {
    $_ports = [ $port ]
  } else {
    $_ports = $ports
  }

  validate_array($_ports)

  file { "${datadog_agent::params::conf_dir}/redisdb.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/redisdb.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
