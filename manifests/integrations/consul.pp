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

  validate_string($url)
  validate_bool($catalog_checks)
  validate_bool($new_leader_checks)
  validate_array($service_whitelist)

  case $::operatingsystem {
    'Ubuntu','Debian' : {
      if versioncmp($datadog_agent::agent_version, '1:5.8') >= 0 {
        $consul_check_filename = 'consul_check.yaml'
        file { "${datadog_agent::params::conf_dir}/consul.yaml":
          ensure => 'absent',
        }
      } else {
        $consul_check_filename = 'consul.yaml'
      }
    }
    'RedHat','CentOS','Fedora','Amazon','Scientific' : {
      if versioncmp($datadog_agent::agent_version, '5.8') >= 0 {
        $consul_check_filename = 'consul_check.yaml'
        file { "${datadog_agent::params::conf_dir}/consul.yaml":
          ensure => 'absent',
        }
      } else {
        $consul_check_filename = 'consul.yaml'
      }
    }
    default: { fail("Class[datadog_agent::integrations::consul]: Unsupported operatingsystem: ${::operatingsystem}") }
  }

  file { "${datadog_agent::params::conf_dir}/${consul_check_filename}":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0644',
    content => template('datadog_agent/agent-conf.d/consul_check.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
