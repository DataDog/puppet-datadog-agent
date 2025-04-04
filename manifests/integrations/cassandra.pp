# Class: datadog_agent::integrations::cassandra
#
# This class will install the necessary configuration for the Cassandra
# integration.
#
# See the sample cassandra.d/conf.yaml for all available configuration options.
# https://github.com/DataDog/integrations-core/blob/master/cassandra/datadog_checks/cassandra/data/conf.yaml.example
#
# See the metrics.yaml file for the list of default collected metrics.
# https://github.com/DataDog/integrations-core/blob/master/cassandra/datadog_checks/cassandra/data/metrics.yaml
#
# This check has a limit of 350 metrics per instance. If you require 
# additional metrics, contact Datadog Support at https://docs.datadoghq.com/help/
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
class datadog_agent::integrations::cassandra (
  String $host                            = 'localhost',
  Integer $port                           = 7199,
  Optional[String] $user                  = undef,
  Optional[String] $password              = undef,
  Hash $tags                              = {},
  Optional[Integer] $max_returned_metrics = undef,
) inherits datadog_agent::params {
  require datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/cassandra.d"

  file { $dst_dir:
    ensure  => directory,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_directory,
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
  $dst = "${dst_dir}/conf.yaml"

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/cassandra.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
