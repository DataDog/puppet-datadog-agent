# Class: datadog_agent::integrations::snmp
#
# This class will enable snmp check
#
# Parameters:
#   $mibs_folder:
#        Optional folder for custom mib files (python format)
#
#   $ignore_nonincreasing_oid:
#        Default: false
#
#   $snmp_v1_instances
#        Array of Hashes containinv snmp version 1 configuration (see snmp.yaml.example for reference)
#
#   $snmp_v2_instances
#        Array of Hashes containinv snmp version 2 configuration (see snmp.yaml.example for reference)
#
#   $snmp_v3_instances
#        Array of Hashes containinv snmp version 3 configuration (see snmp.yaml.example for reference)
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::snmp':
#     snmp_v2_instances => [
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
  $snmp_v1_instances        = [],
  $snmp_v2_instances        = [],
  $snmp_v3_instances        = [],
) inherits datadog_agent::params {
  include ::datadog_agent

  $_instances = {
    1 => $snmp_v1_instances,
    2 => $snmp_v2_instances,
    3 => $snmp_v3_instances,
  }

  $legacy_dst = "${datadog_agent::conf_dir}/snmp.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/snmp.d"
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
    content => template('datadog_agent/agent-conf.d/snmp.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
