# Class: datadog_agent::integrations::marathon
#
# This class will install the necessary configuration for the Marathon integration
#
# See the sample marathon.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/marathon/datadog_checks/marathon/data/conf.yaml.example
#
# Parameters:
#   $url:
#     The URL for Marathon
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::marathon' :
#     url  => "http://localhost:8080"
#   }
#
class datadog_agent::integrations::marathon (
  Integer $marathon_timeout = 5,
  String $url               = 'http://localhost:8080'
) inherits datadog_agent::params {
  require datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/marathon.d"

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
    mode    => $datadog_agent::params::permissions_file,
    content => template('datadog_agent/agent-conf.d/marathon.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
