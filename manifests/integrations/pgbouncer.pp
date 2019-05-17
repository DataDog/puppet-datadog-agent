# Class: datadog_agent::integrations::pgbouncer
#
# This class will install the necessary configuration for the pgbouncer integration
#
# Parameters:
#   $password:
#       The password for the datadog user
#   $host:
#       The host pgbouncer is listening on
#   $port:
#       The pgbouncer port number
#   $username:
#       The username for the datadog user
#   $tags:
#       Optional array of tags
#   $pgbouncers:
#       Optional array of pgbouncer hashes. See example
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::pgbouncer' :
#    host           => 'localhost',
#    username       => 'datadog',
#    port           => '6432',
#    password       => 'some_pass',
#  }
#
#  class { 'datadog_agent::integrations::pgbouncer' :
#    pgbouncers     => [
#      {
#        'host'     => 'localhost',
#        'username' => 'datadog',
#        'port'     => '6432',
#        'password' => 'some_pass',
#        'tags'     => ['instance:one'],
#      },
#      {
#        'host'     => 'localhost',
#        'username' => 'datadog2',
#        'port'     => '6433',
#        'password' => 'some_pass2',
#      },
#    ],
#  }
#
class datadog_agent::integrations::pgbouncer(
  String $password               = '',
  String $host                   = 'localhost',
  Variant[String, Integer] $port = '6432',
  String $username               = 'datadog',
  Array $tags = [],
  Array $pgbouncers = [],
) inherits datadog_agent::params {
  include datadog_agent

  validate_legacy('Array', 'validate_array', $tags)
  validate_legacy('Array', 'validate_array', $pgbouncers)

  $legacy_dst = "${datadog_agent::conf_dir}/pgbouncer.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/pgbouncer.d"
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
    content => template('datadog_agent/agent-conf.d/pgbouncer.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
