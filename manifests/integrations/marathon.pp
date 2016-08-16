# Class: datadog_agent::integrations::marathon
#
# lint:ignore:80chars
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
) inherits datadog_agent::params { # lint:ignore:class_inherits_from_params_class

  file { "${datadog_agent::params::conf_dir}/marathon.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0644',
    content => template('datadog_agent/agent-conf.d/marathon.yaml.erb'),
    require => Class['datadog_agent'],
    notify  => Service[$datadog_agent::params::service_name]
  }
# lint:endignore
}
