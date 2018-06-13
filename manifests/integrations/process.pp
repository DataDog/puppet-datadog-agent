# Class: datadog_agent::integrations::process
#
# This class will install the necessary configuration for the process integration
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
class datadog_agent::integrations::process(
  Boolean $hiera_processes = false,
  Array $processes = [],
  ) inherits datadog_agent::params {
  include datadog_agent


  if $hiera_processes {
    $local_processes = lookup({ 'name' => 'datadog_agent::integrations::process::processes', 'default_value' => []})
  } else {
    $local_processes = $processes
  }

  if !$::datadog_agent::agent5_enable {
    $dst = "${datadog_agent::conf6_dir}/process.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/process.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/process.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
