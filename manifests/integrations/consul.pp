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
  String $url                        = 'http://localhost:8500',
  Boolean $catalog_checks            = true,
  Boolean $network_latency_checks    = true,
  Boolean $new_leader_checks         = true,
  Optional[Array] $service_whitelist = []
) inherits datadog_agent::params {
  include datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/consul.yaml"
  if $::datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/consul.d"
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
    mode    => $datadog_agent::params::permissions_file,
    content => template('datadog_agent/agent-conf.d/consul.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
