# Class: datadog_agent::integrations::storm
#
#
# Parameters:
#  server 
#       (Required) The name of the instance.
#


class datadog_agent::integrations::storm(
  $server                       = "http://localhost:8080",
  $environment			= $::environment,
) inherits datadog_agent::params {
  include datadog_agent

  file { "${datadog_agent::params::checks_dir}/storm.py":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    source  => "puppet:///modules/datadog_agent/checks.d/storm.py",
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }

  file { "${datadog_agent::params::conf_dir}/storm.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/storm.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
