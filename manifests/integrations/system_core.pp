# Class: datadog_agent::integrations::system_core
#
# This class will install the necessary configuration for the system_core integration
#
# Sample Usage:
#   include 'datadog_agent::integrations::system_core'
#
#
class datadog_agent::integrations::system_core inherits datadog_agent::params {
  include datadog_agent

  file {
    "${datadog_agent::params::conf_dir}/system_core.yaml":
      ensure  => file,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0644',
      content => template('datadog_agent/agent-conf.d/system_core.yaml.erb'),
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name]
  }
}
