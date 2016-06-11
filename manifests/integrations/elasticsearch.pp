# Class: datadog_agent::integrations::elasticsearch
#
# lint:ignore:80chars
# This class will install the necessary configuration for the elasticsearch integration
#
# Parameters:
#   $url:
#     The URL for Elasticsearch
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::elasticsearch' :
#     url  => "http://localhost:9201"
#   }
#
class datadog_agent::integrations::elasticsearch(
  $url = 'http://localhost:9200'
) inherits datadog_agent::params { # lint:ignore:class_inherits_from_params_class

  file { "${datadog_agent::params::conf_dir}/elastic.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0644',
    content => template('datadog_agent/agent-conf.d/elastic.yaml.erb'),
    require => [Class['datadog_agent'],Package[$datadog_agent::params::package_name]],
    notify  => Service[$datadog_agent::params::service_name]
  }
# lint:endignore
}
