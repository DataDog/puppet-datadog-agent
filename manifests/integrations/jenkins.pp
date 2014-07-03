# Class: datadog::integrations::jenkins
#
# This class will install the necessary configuration for the jenkins integration
#
# Parameters:
#   $path:
#       Jenkins path. Defaults to '/var/lib/jenkins'
#
# Sample Usage:
#
#  class { 'datadog::integrations::jenkins' :
#    path     => '/var/lib/jenkins',
#  }
#
#
class datadog::integrations::jenkins(
  $path = '/var/lib/jenkins'
) inherits datadog::params {

  file { "${conf_dir}/jenkins.yaml":
    ensure  => file,
    owner   => $dd_user,
    group   => $dd_group,
    mode    => 0600,
    content => template('datadog/agent-conf.d/jenkins.yaml.erb'),
    notify  => Service[$service_name]
  }
}
