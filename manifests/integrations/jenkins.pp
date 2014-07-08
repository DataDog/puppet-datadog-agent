# Class: datadog_agent::integrations::jenkins
#
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
) inherits datadog_agent::params {

  file { "${conf_dir}/jenkins.yaml":
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::dd_group,
    mode    => 0600,
    content => template('datadog_agent/agent-conf.d/jenkins.yaml.erb'),
    notify  => Service[$service_name]
  }
}
