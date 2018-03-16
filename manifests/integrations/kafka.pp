# Class: datadog_agent::integrations::kafka
#
# This class will install the necessary configuration for the kafka
# integration
#
# Parameters:
#   $host:
#       The hostname kafka is running on
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
#  class { 'datadog_agent::integrations::kafka' :
#    host     => 'localhost',
#    tags     => {
#      environment => "production",
#    },
#  }
#
#
class datadog_agent::integrations::kafka(
  $host = 'localhost',
  $port = 9999,
  $user = undef,
  $password = undef,
  $tags = { kafka => broker },
) inherits datadog_agent::params {
  require ::datadog_agent
  validate_hash($tags)

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/kafka.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/kafka.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/kafka.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
