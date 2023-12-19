# Class: datadog_agent::integrations::mongo
#
# This class will install the necessary configuration for the mongo integration
#
# NOTE: In newer versions of the Datadog Agent, the ssl parameters will be deprecated in favor the tls variants
#
# Parameters:
#   @param servers
#
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
class datadog_agent::integrations::mongo (
  Array $servers = [{ 'host' => 'localhost', 'port' => '27017' }],
) inherits datadog_agent::params {
  require datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/mongo.yaml"
  if versioncmp($datadog_agent::_agent_major_version, '5') > 0 {
    $dst_dir = "${datadog_agent::params::conf_dir}/mongo.d"
    file { $legacy_dst:
      ensure => 'absent',
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name],
    }
    $dst = "${dst_dir}/conf.yaml"
  } else {
    $dst = $legacy_dst
  }

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
