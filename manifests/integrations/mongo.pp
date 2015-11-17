# Class: datadog_agent::integrations::mongo
#
# This class will install the necessary configuration for the mongo integration
#
# Parameters:
#   $additional_metrics
#       Optional array of additional metrics
#   $database
#       Optionally specify database to query. Defaults to 'admin'
#   $host:
#       The host mongo is running on. Defaults to '127.0.0.1'
#   $password
#       Optionally specify password for connection
#   $port
#       The port mongo is running on. Defaults to 27017
#   $ssl
#       Optionally enable SSL for connection
#   $ssl_ca_certs
#       Optionally specify path to SSL Certificate Authority certificates
#   $ssl_cert_reqs
#       Optionally require SSL client certificate for connection
#   $ssl_certfile
#       Optionally specify path to SSL certificate for connection
#   $ssl_keyfile
#       Optionally specify path to SSL private key for connection
#   $tags
#       Optional array of tags
#   $username
#       Optionally specify username for connection
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::mongo' :
#    servers => [
#      {
#        'additional_metrics' => ['top'],
#        'database'           => 'database_name',
#        'host'               => 'localhost',
#        'password'           => 'mongo_password',
#        'port'               => '27017',
#        'ssl'                => true,
#        'ssl_ca_certs'       => '/path/to/ca.pem',
#        'ssl_cert_reqs'      => 'CERT_REQUIRED',
#        'ssl_certfile'       => '/path/to/client.pem',
#        'ssl_keyfile'        => '/path/to/key.pem',
#        'tags'               => ['optional_tag1', 'optional_tag2'],
#        'username'           => 'mongo_username',
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
  include datadog_agent

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
