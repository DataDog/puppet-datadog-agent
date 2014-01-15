# Class: datadog::integrations::elastic
#
# This class will install the necessary configuration for the Elasticsearch integration
#
# Parameters:
#   $url:
#       Elasticsearch REST endpoint. Defaults to 'http://localhost:9200'
#
# Sample Usage:
#
#  class { 'datadog::integrations::elastic' :
#    url  => 'http://localhost:9200',
#  }
#
#
class datadog::integrations::elastic(
  $url = 'http://localhost:9200'
) inherits datadog::params {

  file { "${conf_dir}/elastic.yaml":
    ensure  => file,
    owner   => $dd_user,
    group   => $dd_group,
    mode    => 0640,
    content => template('datadog/integrations/elastic.yaml.erb'),
    notify  => Service[$service_name]
  }
}
