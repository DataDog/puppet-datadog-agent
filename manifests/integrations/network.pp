# Class: datadog_agent::integrations::network
#
# This class will install the network integration
#
# Parameters:
#   @param collect_connection_state
#       Enable TCP connection state counts
#   @param collect_connection_queues
#   @param excluded_interfaces
#   @param excluded_interface_re
#   @param collect_rate_metrics
#   @param collect_count_metrics
#   @param conntrack_path
#   @param use_sudo_conntrack
#   @param whitelist_conntrack_metrics
#   @param blacklist_conntrack_metrics
#   @param collect_aws_ena_metrics
#   @param tags
#   @param service
#   @param min_collection_interval
#   @param empty_default_hostname
#   @param metric_patterns_include
#   @param metric_patterns_exclude
#   @param combine_connection_states
#
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::network' :
#    collect_connection_state     => false,
#    excluded_interfaces => [
#     'lo0',
#     'lo',
#    ],
#    excluded_interface_re = 'eth1.*',
#    combine_connection_states => true
#  }
#
#
class datadog_agent::integrations::network (
  Boolean $collect_connection_state          = false,
  Boolean $collect_connection_queues         = false,
  Array[String] $excluded_interfaces         = [],
  Optional[String] $excluded_interface_re    = undef,
  Boolean $combine_connection_states         = true,
  Boolean $collect_rate_metrics              = true,
  Boolean $collect_count_metrics             = false,
  Optional[String] $conntrack_path           = undef,
  Boolean $use_sudo_conntrack                = true,
  Array[String] $whitelist_conntrack_metrics = [],
  Array[String] $blacklist_conntrack_metrics = [],
  Boolean $collect_aws_ena_metrics           = false,
  Array[String] $tags                        = [],
  Optional[String] $service                  = undef,
  Integer $min_collection_interval           = 15,
  Boolean $empty_default_hostname            = false,
  Array[String] $metric_patterns_include     = [],
  Array[String] $metric_patterns_exclude     = [],
) inherits datadog_agent::params {
  require datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/network.yaml"
  if versioncmp($datadog_agent::_agent_major_version, '5') > 0 {
    $dst_dir = "${datadog_agent::params::conf_dir}/network.d"
    file { $legacy_dst:
      ensure => 'absent',
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name],
    }
    $dst = "${dst_dir}/conf.yaml"
  } else {
    $dst = $legacy_dst
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/network.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
