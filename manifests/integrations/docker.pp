# Class: datadog_agent::integrations::docker
#
# This class will install the necessary configuration for the docker integration
#
# Parameters:
#   $new_tag_names:
#     Update docker new tags
#
#   $url:
#     The URL for docker API
#
#   $tags:
#     optional array of tags
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::docker' :
#     new_tag_names => true,
#     url           => 'unix://var/run/docker.sock',
#   }
#
class datadog_agent::integrations::docker(
  $new_tag_names = true,
  $url = 'unix://var/run/docker.sock',
  $tags = [],
) inherits datadog_agent::params {

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
