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
  $host = 'localhost',
  $port = 7199,
  $user = undef,
  $password = undef,
  $tags = {},
) inherits datadog_agent::params {
  require ::datadog_agent
  validate_hash($tags)

  file { "${datadog_agent::params::conf_dir}/cassandra.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/cassandra.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
