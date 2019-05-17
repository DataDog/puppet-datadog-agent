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
  Boolean $collect_connection_state = false,
  Array[String] $excluded_interfaces = ['lo','lo0'],
  Array $excluded_interface_re = [],
  Boolean $combine_connection_states = true,
) inherits datadog_agent::params {
  include ::datadog_agent

  validate_legacy('Array', 'validate_array', $excluded_interfaces)

  $legacy_dst = "${datadog_agent::conf_dir}/network.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/network.d"
    file { $legacy_dst:
      ensure => 'absent'
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0755',
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
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/network.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
