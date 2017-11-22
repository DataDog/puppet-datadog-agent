# Class: datadog_agent::integrations::kubernetes
#
# This class will install the necessary configuration for the kubernetes integration
#
# Parameters:
#   $url:
#     The URL for kubernetes metrics 
#
#   $tags:
#     optional array of tags
#
#
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::kubernetes_state' :
#     url  => 'http://kubernetes.com:8080/metrics',
#   }
#
class datadog_agent::integrations::kubernetes_state(
  $url = 'Enter_State_URL',
  $tags = [],

) inherits datadog_agent::params {
  include datadog_agent

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/kubernetes_state.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/kubernetes_state.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0644',
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
    content => template('datadog_agent/agent-conf.d/kubernetes_state.yaml.erb'),
  }
}
