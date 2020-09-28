# Class: datadog_agent::integrations::oom_kill
#
# This class will install the necessary configuration for the oom_kill integration
# For it to work you also need to enable the system-probe with enable_oom_kill set to true.
#
# Parameters:
#   $instances:
#       Array of hashes for all oom_kill configs and associates tags. See example
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::oom_kill':
#     instances => [
#         {
#             'collect_oom_kill'  => true,
#             'tags' => ['instance:foo'],
#         },
#     ],
#   }
#

class datadog_agent::integrations::oom_kill(
  Array $instances = [],
) inherits datadog_agent::params {
  include datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/oom_kill.d"
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

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/oom_kill.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
