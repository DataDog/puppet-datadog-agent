# Class: datadog_agent::integrations::network
#
# This class will install the network integration
#
# Parameters:
#   $collect_connection_state
#       Enable TCP connection state counts
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::network' :
#    collect_connection_state     => false,
#    excluded_interfaces => [
#     'lo0',
#     'lo',
#    ],
#    excluded_interface_re => [
#    'eth1.*'
#    ]
#    combine_connection_states => true
#  }
#
#
class datadog_agent::integrations::network(
  $collect_connection_state = false,
  $excluded_interfaces = ['lo','lo0'],
  $excluded_interface_re = [],
  $combine_connection_states = true,
) inherits datadog_agent::params {
  include ::datadog_agent

  validate_array($excluded_interfaces)

  file { "${datadog_agent::params::conf_dir}/network.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/network.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
