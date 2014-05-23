# Class: datadog::integrations::elasticsearch
#
# This class will install the necessary configuration for the mongodb integration
#
# Parameters:
# $elastic_host
#    The host where elasticsearch is running
#
# $elastic_port
#    The port on which the elasticsearch status endpoint can be reached
#
# Sample Usage:
#
#  class { 'datadog::integrations::elasticsearch' :
#    host     => 'localhost',
#    port     => 9200
#  }
#
#
class datadog::integrations::elasticsearch(
  $elastic_host = 'localhost',
  $elastic_port = 9200
) inherits datadog::params {

  file { "${conf_dir}/elastic.yaml":
    ensure  => file,
    owner   => $dd_user,
    group   => $dd_group,
    mode    => 0644,
    content => template('datadog/elasticsearch.yaml.erb'),
    notify  => Service[$service_name]
  }
}
