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
#   $command_stats
#       Collect INFO COMMANDSTATS output as metrics
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::redis' :
#    host => 'localhost',
#  }
#
#
class datadog_agent::integrations::redis(
  String $host                              = 'localhost',
  String $password                          = '',
  Variant[String, Integer] $port            = '6379',
  Optional[Array] $ports                    = undef,
  Variant[String, Integer] $slowlog_max_len = '',
  Array $tags                               = [],
  Array $keys                               = [],
  Boolean $warn_on_missing_keys             = true,
  Boolean $command_stats                    = false,

) inherits datadog_agent::params {
  include datadog_agent


  if $ports == undef {
    $_ports = [ $port ]
  } else {
    $_ports = $ports
  }


  if !$::datadog_agent::agent5_enable {
    $dst = "${datadog_agent::conf6_dir}/redisdb.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/redisdb.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/redisdb.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
