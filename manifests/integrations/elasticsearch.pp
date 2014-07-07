# Class: datadog::integrations::elasticsearch
#
# This class will install the necessary configuration for the elasticsearch integration
#
# Parameters:
#   $url:
#     The URL for Elasticsearch
#
# Sample Usage:
#
#   class { 'datadog::integrations::elasticsearch' :
#     url  => "http://localhost:9201"
#   }
#
class datadog::integrations::elasticsearch(
  $url = 'http://localhost:9200'
) inherits datadog::params {

  file { "${datadog::conf_dir}/elastic.yaml":
    ensure  => file,
    owner   => $datadog::dd_user,
    group   => $datadog::dd_group,
    mode    => '0644',
    content => template('datadog/agent-conf.d/elastic.yaml.erb'),
    require => Package[ 'datadog-agent' ],
    notify  => Service[ $datadog::service_name ],
  }
}
