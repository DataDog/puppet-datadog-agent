# Class: datadog_agent::integrations::marathon
#
# This class will install the necessary configuration for the Marathon integration
#
# Parameters:
#   $url:
#     The URL for Marathon
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::marathon' :
#     url  => "http://localhost:8080"
#   }
#
class datadog_agent::integrations::marathon(
  $marathon_timeout = 5,
  $url = 'http://localhost:8080'
) inherits datadog_agent::params {
  include datadog_agent

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/marathon.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/marathon.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0644',
    content => template('datadog_agent/agent-conf.d/marathon.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
