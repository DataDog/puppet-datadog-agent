# Class: datadog_agent::integrations::redis
#
# This class will install the necessary configuration for the redis integration
#
# See the sample redisdb.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/redisdb/datadog_checks/redisdb/data/conf.yaml.example
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
#   $ssl
#       Enable SSL/TLS encryption for the check (optional)
#   $ssl_keyfile
#       The path to the client-side private keyfile (optional)
#   $ssl_certfile
#       The path to the client-side certificate file (optional)
#   $ssl_ca_certs
#       The path to the ca_certs file (optional)
#   $ssl_cert_reqs
#       Specifies whether a certificate is required from the
#       other side of the connection, and whether it's validated if provided (optional)
#         * 0 for ssl.CERT_NONE (certificates ignored)
#         * 1 for ssl.CERT_OPTIONAL (not required, but validated if provided)
#         * 2 for ssl.CERT_REQUIRED (required and validated)
#   $slowlog_max_len
#       The max length of the slow-query log (optional)
#   $tags
#       Optional array of tags
#   $keys
#       Optional array of keys to check length
#   $command_stats
#       Collect INFO COMMANDSTATS output as metrics
#   $instances
#       Optional array of hashes should you wish to specify multiple instances.
#       If this option is specified all other parameters will be overriden.
#       This parameter may also be used to specify instances with hiera.
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::redis' :
#    host => 'localhost',
#  }
#
# Hiera Usage:
#
#   datadog_agent::integrations::redis::instances:
#     - host: 'localhost'
#       password: 'datadog'
#       port: 6379
#       slowlog_max_len: 1000
#       warn_on_missing_keys: true
#       command_stats: false
#
class datadog_agent::integrations::redis (
  String $host                              = 'localhost',
  String $password                          = '',
  Variant[String, Integer] $port            = '6379',
  Optional[Array] $ports                    = undef,
  Boolean $ssl                              = false,
  String $ssl_keyfile                       = '',
  String $ssl_certfile                      = '',
  String $ssl_ca_certs                      = '',
  Optional[Integer] $ssl_cert_reqs          = undef,
  Variant[String, Integer] $slowlog_max_len = '',
  Array $tags                               = [],
  Array $keys                               = [],
  Boolean $warn_on_missing_keys             = true,
  Boolean $command_stats                    = false,
  Optional[Array] $instances                = undef,

) inherits datadog_agent::params {
  require datadog_agent

  if $ports == undef {
    $_ports = [$port]
  } else {
    $_ports = $ports
  }

  $_port_instances = $_ports.map |$instance_port| {
    {
      'host'                 => $host,
      'password'             => $password,
      'port'                 => $instance_port,
      'ssl'                  => $ssl,
      'ssl_keyfile'          => $ssl_keyfile,
      'ssl_certfile'         => $ssl_certfile,
      'ssl_ca_certs'         => $ssl_ca_certs,
      'ssl_cert_reqs'        => $ssl_cert_reqs,
      'slowlog_max_len'      => $slowlog_max_len,
      'tags'                 => $tags,
      'keys'                 => $keys,
      'warn_on_missing_keys' => $warn_on_missing_keys,
      'command_stats'        => $command_stats,
    }
  }

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/redisdb.yaml"
  if $datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/redisdb.d"
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

  if !$instances and $host {
    $_instances = $_port_instances
  } elsif !$instances {
    $_instances = []
  } else {
    $_instances = $instances
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/redisdb.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
