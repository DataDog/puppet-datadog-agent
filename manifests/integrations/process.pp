# Class: datadog::integrations::process
#
# This class will install the necessary configuration for the process integration
#
# Parameters:
#   $processes:
#       Array of process hashes. See example
#
# Sample Usage:
#
# class { 'datadog::integrations::process':
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
class datadog::integrations::process(
  $processes = [],
) inherits datadog::params {

  validate_array( $processes )

  package { $process_int_package :
    ensure => installed,
  }

  file { "${conf_dir}/process.yaml":
    ensure  => file,
    owner   => $datadog::dd_user,
    group   => $datadog::dd_group,
    mode    => 0600,
    content => template('datadog/agent-conf.d/process.yaml.erb'),
    require => Package[$process_int_package],
    notify  => Service[$service_name]
  }
}
