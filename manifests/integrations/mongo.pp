# Class: datadog_agent::integrations::mongo
#
# This class will install the necessary configuration for the mongo integration
#
# See the sample mongo.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/mongo/datadog_checks/mongo/data/conf.yaml.example
#
# NOTE: In newer versions of the Datadog Agent, the ssl parameters will be deprecated in favor the tls variants
#
# Parameters:
#   $hosts
#       Array of hosts host (and optional port number) where the mongod instance is running
#   $dbm
#       Enable the Database Monitoring feature
#   $database_autodiscovery
#       Enable the Database Autodiscovery feature
#   $reported_database_hostname
#       Optional database hostname override the mongodb hostname detected by the Agent from mongodb admin command serverStatus
#   $additional_metrics
#       Optional array of additional metrics
#   $database
#       Optionally specify database to query. Defaults to 'admin'
#   $password
#       Optionally specify password for connection
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
#   $tls
#       Optionally enable TLS for connection
#   $tls_ca_file
#       Optionally specify path to SSL/TLS Certificate Authority certificates
#   $tls_allow_invalid_certificates
#       Optionally require SSL/TLS client certificate for connection
#   $tls_certificate_key_file
#       Optionally specify path to combined SSL/TLS key and certificate for connection
#   $tags
#       Optional array of tags
#   $username
#       Optionally specify username for connection
#   $host:
#       Deprecated use $hosts instead
#       The host mongo is running on. Defaults to '127.0.0.1'
#   $port
#       Deprecated use $hosts instead
#       The port mongo is running on. Defaults to 27017
#
# Sample Usage (Older Agent Versions):
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
#        'host'               => 'localhost',
#        'port'               => '27018',
#        'tags'               => [],
#        'additional_metrics' => [],
#        'collections'        => [],
#      },
#    ]
#  }
#
# Sample Usage (Newer Agent Versions):
#
#  class { 'datadog_agent::integrations::mongo' :
#    servers => [
#      {
#        'additional_metrics' => ['top'],
#        'database'           => 'database_name',
#        'hosts'              => ['localhost:27017'],
#        'password'           => 'mongo_password',
#        'tls'                => true,
#        'tls_ca_file'       => '/path/to/ca.pem',
#        'tls_allow_invalid_certificates'      => false,
#        'tls_certificate_key_file'       => '/path/to/combined.pem',
#        'tags'               => ['optional_tag1', 'optional_tag2'],
#        'username'           => 'mongo_username',
#        'dbm'                => true,
#        'database_autodiscovery' => {'enabled' => true},
#        'reported_database_hostname' => 'mymongodbhost',
#      },
#      {
#        'hosts'              => ['localhost:27017'],
#        'tags'               => [],
#        'additional_metrics' => [],
#        'collections'        => [],
#      },
#    ]
#  }
#
class datadog_agent::integrations::mongo (
  Array $servers = [{ 'host' => 'localhost', 'port' => '27017' }]
) inherits datadog_agent::params {
  require datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/mongo.d"

  file { $dst_dir:
    ensure  => directory,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_directory,
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
  $dst = "${dst_dir}/conf.yaml"

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/mongo.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
