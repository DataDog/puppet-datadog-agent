# Class: datadog_agent::integrations::cassandra
#
# This class will install the necessary configuration for the Cassandra
# integration
#
# Parameters:
#   $host:
#       The hostname Cassandra is running on
#   $port:
#       The port to connect on
#   $user
#       The user for the datadog user
#   $password
#       The password for the datadog user
#   $tags
#       Optional array of tags
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::cassandra' :
#    host     => 'localhost',
#    tags     => {
#      environment => "production",
#    },
#  }
#
#
class datadog_agent::integrations::cassandra(
  String $host               = 'localhost',
  Integer $port              = 7199,
  Optional[String] $user     = undef,
  Optional[String] $password = undef,
  Optional[Hash] $tags       = {},
) inherits datadog_agent::params {
  require ::datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/cassandra.yaml"
  if $::datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/cassandra.d"

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
    content => template('datadog_agent/agent-conf.d/cassandra.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
