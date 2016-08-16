# Class: datadog_agent::integrations::jenkins
#
# lint:ignore:80chars
# This class will install the necessary configuration for the jenkins integration
#
# Parameters:
#   $path:
#       Jenkins path. Defaults to '/var/lib/jenkins'
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::jenkins' :
#    path     => '/var/lib/jenkins',
#  }
#
#
class datadog_agent::integrations::jenkins(
  $path = '/var/lib/jenkins'
) inherits datadog_agent::params { # lint:ignore:class_inherits_from_params_class

  file { "${datadog_agent::params::conf_dir}/jenkins.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/jenkins.yaml.erb'),
    require => Class['datadog_agent'],
    notify  => Service[$datadog_agent::params::service_name]
  }
# lint:endignore
}
