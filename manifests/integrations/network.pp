# Class: datadog_agent::integrations::network
#
# This class will install the network integration
#
# See the sample network.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/network/datadog_checks/network/data/conf.yaml.default
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
#    excluded_interface_re = 'eth1.*',
#    combine_connection_states => true
#  }
#
#
class datadog_agent::integrations::network (
  Boolean $collect_connection_state          = false,
  Boolean $collect_connection_queues         = false,
  Array[String] $excluded_interfaces         = [],
  String $excluded_interface_re              = '',
  Boolean $combine_connection_states         = true,
  Boolean $collect_rate_metrics              = true,
  Boolean $collect_count_metrics             = false,
  String $conntrack_path                     = '',
  Boolean $use_sudo_conntrack                = true,
  Array[String] $whitelist_conntrack_metrics = [],
  Array[String] $blacklist_conntrack_metrics = [],
  Boolean $collect_aws_ena_metrics           = false,
  Array[String] $tags                        = [],
  String $service                            = '',
  Integer $min_collection_interval           = 15,
  Boolean $empty_default_hostname            = false,
  Array[String] $metric_patterns_include     = [],
  Array[String] $metric_patterns_exclude     = [],
) inherits datadog_agent::params {
  require datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/network.d"

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
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/network.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
