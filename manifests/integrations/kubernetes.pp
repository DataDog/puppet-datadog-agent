# Class: datadog_agent::integrations::kubernetes
#
# This class will install the necessary configuration for the kubernetes integration
#
# Parameters: 
#   $url:
#     The URL for kubernetes API
#
#   $tags:
#     optional array of tags
#
#
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::kubernetes' :
#     api_server_url  => 'https://kubernetes:443',
#   }
#
class datadog_agent::integrations::kubernetes(
  $api_server_url = 'Enter_Your_API_url',
  $tags = []
) inherits datadog_agent::params {
  include datadog_agent

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/kubernetes.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/kubernetes.yaml"
  }

  package { 'dd-check-kubernetes':
    ensure => present,
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0644',
    content => template('datadog_agent/agent-conf.d/kubernetes.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
