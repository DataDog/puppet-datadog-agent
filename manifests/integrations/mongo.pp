# Class: datadog_agent::integrations::mongo
#
# This class will install the necessary configuration for the mongo integration
#
# Parameters:
#   $host:
#       The host mongo is running on. Defaults to '127.0.0.1'
#   $port
#       The mongo password for the datadog user. Defaults to 27017
#   $tags
#       Optional array of tags
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::mongo' :
#    host     => 'localhost',
#    port     => 27017,
#  }
#
#
class datadog_agent::integrations::mongo(
  $host = '127.0.0.1',
  $port = 27017,
  $tags = []
) inherits datadog_agent::params {

  validate_array( $tags )

  package { $mongo_int_package :
    ensure => installed,
  }

  file { "${conf_dir}/mongo.yaml":
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::dd_group,
    mode    => 0600,
    content => template('datadog_agent/agent-conf.d/mongo.yaml.erb'),
    require => Package[$mongo_int_package],
    notify  => Service[$service_name]
  }
}
