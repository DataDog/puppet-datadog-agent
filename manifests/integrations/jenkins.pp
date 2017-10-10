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
  include datadog_agent

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/jenkins.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/jenkins.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/jenkins.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
