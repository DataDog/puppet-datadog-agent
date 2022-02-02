# Class: datadog_agent::integrations::snmp
#
# This class will enable snmp check
#
# Parameters:
#   $init_config:
#       Optional hash (see snmp.yaml.example for reference)
#
#   $instances:
#        Array of hashes containing snmp instance configuration (see snmp.yaml.example for reference)
#
#   $mibs_folder: (Deprecated in favor of $init_config)
#   $ignore_nonincreasing_oid: (Deprecated in favor of $init_config)
#   $snmp_v1_instances: (Deprecated in favor of $instances)
#   $snmp_v2_instances: (Deprecated in favor of $instances)
#   $snmp_v3_instances: (Deprecated in favor of $instances)
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::snmp':
#     instances => [
#       {
#         ip_address       => 'localhost',
#         port             => 161,
#         community_string => 'public',
#         tags             => [
#           'optional_tag_1',
#         ],
#         metrics          => [
#           {
#             MIB         => 'IF-MIB',
#             table       => 'ifTable',
#             symbols     => [
#               'ifInOctets',
#               'ifOutOctets',
#             ],
#             metric_tags => [
#               {
#                 tag    => 'interface',
#                 column => 'ifDescr',
#               },
#               {
#                 tag    => 'interface_index',
#                 column => 'ifIndex',
#               },
#             ],
#           },
#         ],
#       }
#     ],
#   }


class datadog_agent::integrations::snmp (
  $mibs_folder              = undef,
  $ignore_nonincreasing_oid = false,
  $init_config              = {},
  $instances                = [],
  $snmp_v1_instances        = [],
  $snmp_v2_instances        = [],
  $snmp_v3_instances        = [],
) inherits datadog_agent::params {
  require ::datadog_agent

  $versioned_instances = {
    1 => $snmp_v1_instances,
    2 => $snmp_v2_instances,
    3 => $snmp_v3_instances,
  }

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/snmp.yaml"
  if $::datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/snmp.d"
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
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/snmp.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
