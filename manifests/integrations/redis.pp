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

  validate_legacy('Array', 'validate_array', $tags)
  validate_legacy('Array', 'validate_array', $keys)
  validate_legacy('Boolean', 'validate_bool', $warn_on_missing_keys)
  validate_legacy('Boolean', 'validate_bool', $command_stats)
  validate_legacy('Optional[Array]', 'validate_array', $ports)

  if $ports == undef {
    $_ports = [ $port ]
  } else {
    $_ports = $ports
  }

  validate_legacy('Array', 'validate_array', $_ports)

  $legacy_dst = "${datadog_agent::conf_dir}/redisdb.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/redisdb.d/conf.yaml"
    file { $legacy_dst:
      ensure => 'absent'
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0755',
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
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/redisdb.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
