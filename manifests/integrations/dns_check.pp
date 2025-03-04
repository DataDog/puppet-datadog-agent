# Class: datadog_agent::integrations::dns_check
#
# This class will install the necessary configuration for the DNS check
# integration.
#
# See the sample dns_check.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/dns_check/datadog_checks/dns_check/data/conf.yaml.example
#
# Parameters:
#   $hostname:
#       Domain or IP you wish to check the availability of.
#   $nameserver
#       The nameserver you wish to use to check the hostname
#       availability.
#   $timeout
#       Time in seconds to wait before terminating the request.
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::dns_check':
#    checks => [
#      {
#        'hostname'   => 'example.com',
#        'nameserver' => '8.8.8.8',
#        'timeout'    => 5,
#      }
#    ]
#  }
#
class datadog_agent::integrations::dns_check (
  Array $checks = [
    {
      'hostname'   => 'google.com',
      'nameserver' => '8.8.8.8',
      'timeout'    => 5,
    },
  ]
) inherits datadog_agent::params {
  require datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/dns_check.d"

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
    content => template('datadog_agent/agent-conf.d/dns_check.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
