# Class: datadog_agent::integrations::system_core
#
# This class will install the necessary configuration for the system_core integration
#
# See the sample system_core.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/system_core/datadog_checks/system_core/data/conf.yaml.example
#
# Sample Usage:
#   include 'datadog_agent::integrations::system_core'
#
#
class datadog_agent::integrations::system_core inherits datadog_agent::params {
  require datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/system_core.d"

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
    content => template('datadog_agent/agent-conf.d/system_core.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
