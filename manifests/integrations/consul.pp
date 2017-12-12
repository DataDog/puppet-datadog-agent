# Class: datadog_agent::integrations::consul
#
# This class will install the necessary configuration for the consul integration
#
# Parameters:
#   $url:
#     The URL for consul
#   $catalog_checks:
#       Whether to perform checks against the Consul service Catalog
#       Optional.
#   $new_leader_checks:
#       Whether to enable new leader checks from this agent
#       Note: if this is set on multiple agents in the same cluster
#       you will receive one event per leader change per agent
#   $service_whitelist
#       Services to restrict catalog querying to
#       The default settings query up to 50 services. So if you have more than
#       this many in your Consul service catalog, you will want to fill in the
#       whitelist
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::consul' :
#     url  => "http://localhost:8500"
#     catalog_checks    => true,
#     new_leader_checks => false,
#   }
#
class datadog_agent::integrations::consul(
  $url               = 'http://localhost:8500',
  $catalog_checks    = true,
  $new_leader_checks = true,
  $service_whitelist = []
) inherits datadog_agent::params {
  include datadog_agent

  validate_string($url)
  validate_bool($catalog_checks)
  validate_bool($new_leader_checks)
  validate_array($service_whitelist)

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/consul.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/consul.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0644',
    content => template('datadog_agent/agent-conf.d/consul.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
