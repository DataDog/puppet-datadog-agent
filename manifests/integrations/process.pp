# Class: datadog_agent::integrations::process
#
# This class will install the necessary configuration for the process integration
#
# See the sample process.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/process/datadog_checks/process/data/conf.yaml.example
#
# Parameters:
#   $processes:
#       Array of process hashes. See example
#   $hiera_processes:
#       Boolean to grab processes from hiera to allow merging
#
# Process hash keys:
#   search_strings
#       LIST OF STRINGS If one of the element in the list matches,
#       return the counter of all the processes that contain the string
#
#   exact_match
#       True/False, default to True, if you want to look for an arbitrary
#       string, use exact_match: False, unless use the exact base name of the process
#
#   cpu_check_interval
#       CPU percent check interval: 0.1 - 1.0 sec. More time - more precise
#       Optional
#
# Sample Usage:
#
# class { 'datadog_agent::integrations::process':
#     processes   => [
#         {
#             'name'          => 'puppetmaster',
#             'search_string' => ['puppet master'],
#             'exact_match'   => false,
#         },
#         {
#             'name'          => 'sshd',
#             'search_string' => ['/usr/sbin/sshd'],
#             'exact_match'   => true,
#         },
#     ],
# }

#
#
class datadog_agent::integrations::process (
  Boolean $hiera_processes = false,
  Hash $init_config        = {},
  Array $processes         = [],
) inherits datadog_agent::params {
  require datadog_agent

  if $hiera_processes {
    $local_processes = lookup({ 'name' => 'datadog_agent::integrations::process::processes', 'merge' => 'unique',
    'default_value'                  => $processes })
  } else {
    $local_processes = $processes
  }

  $dst_dir = "${datadog_agent::params::conf_dir}/process.d"

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
    ensure  => $local_processes.length ? {
      0       => 'absent',
      default => file
    },
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/process.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
