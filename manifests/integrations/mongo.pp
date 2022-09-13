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
#        'tls'                => true,
#        'tls_ca_file'       => '/path/to/ca.pem',
#        'tls_allow_invalid_certificates'      => false,
#        'tls_certificate_key_file'       => '/path/to/combined.pem',
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
class datadog_agent::integrations::mongo(
  Array $servers = [{'host' => 'localhost', 'port' => '27017'}]
) inherits datadog_agent::params {
  require ::datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/mongo.yaml"
  if $::datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/mongo.d"
    file { $legacy_dst:
      ensure => 'absent'
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name]
    }
    $dst = "${dst_dir}/conf.yaml"
  } else {
    $dst = $legacy_dst
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/mongo.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
