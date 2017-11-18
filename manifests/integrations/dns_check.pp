# Class: datadog_agent::integrations::dns_check
#
# This class will install the necessary configuration for the DNS check
# integration.
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
  $checks = [
    {
      'hostname'   => 'google.com',
      'nameserver' => '8.8.8.8',
      'timeout'    => 5,
    }
  ]
) inherits datadog_agent::params {
  include datadog_agent

  validate_array($checks)

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/dns_check.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/dns_check.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/dns_check.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
