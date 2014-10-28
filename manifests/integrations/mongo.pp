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
#    servers => [
#      {
#        'host' => 'localhost',
#        'port' => '27017',
#        'tags' => [],
#      },
#      {
#        'host' => 'localhost',
#        'port' => '27018',
#        'tags' => [],
#      },
#    ]
#  }
#
class datadog_agent::integrations::mongo(
  $servers = [{'host' => 'localhost', 'port' => '27017'}]
) inherits datadog_agent::params {

  validate_array($servers)

  file { "${datadog_agent::params::conf_dir}/mongo.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/mongo.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
