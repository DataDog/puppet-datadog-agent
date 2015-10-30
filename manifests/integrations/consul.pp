# Class: datadog_agent::integrations::consul
#
# This class will install the necessary configuration for the consul integration
#
# Parameters:
#   $url:
#     The URL for communicating with consul
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::consul' :
#     url  => 'http://localhost:8500',
#     catalog_checks => true,
#     new_leader_checks => true,
#     service_whitelist = []
#   }
#
class datadog_agent::integrations::consul(
  $url = 'http://localhost:8500',
  $catalog_checks = true,
  $new_leader_checks = true,
  $service_whitelist = []
) inherits datadog_agent::params {

  file { "${datadog_agent::params::conf_dir}/consul.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0644',
    content => template('datadog_agent/agent-conf.d/consul.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
