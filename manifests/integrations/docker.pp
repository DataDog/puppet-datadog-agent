# Class: datadog_agent::integrations::docker
#
# This class will install the necessary configuration for the docker integration
#
# Parameters:
#   $tags
#       Optional array of tags
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::docker' :
#   }
#
class datadog_agent::integrations::docker(
  $tags      = []
) inherits datadog_agent::params {

  validate_array($tags)

  file { "${datadog_agent::params::conf_dir}/docker.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0644',
    content => template('datadog_agent/agent-conf.d/docker.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
