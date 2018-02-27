# Class: datadog_agent::integrations::kafka
#
# This class will install the necessary configuration for the kafka integration
#
# Parameters:
#   $host:
#       The host kafka is running on. Defaults to 'localhost'
#   $username
#       Optionally specify username for connection
#   $password
#       Optionally specify password for connection
#   $port
#       The port kafka is running on. Defaults to 9999
#   $name
#       Name given to kafka instance
#   $process_name_regex
#       Instead of specifying a host, and port. The agent can connect using the attach api.
#   $tools_jar_path
#       Path to tools jar needs to be set when process_name_regex is set
#   $java_bin_path
#       Path to java binary, should be set if agent cant find your java executable
#   $trust_store_path
#       Path to the trust store, should be set if ssl is enabled
#   $trust_store_password
#       Password to the trust store
#   $tags
#       Optional array of tags
#
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::kafka' :
#    servers => [
#      {
#        'host'                 => 'localhost',
#        'username'             => 'kafka_username',
#        'password'             => 'kafka_password',
#        'port'                 => '9999',
#        'name'                 => 'kafka_instance',
#        'process_name_regex'   => '.*process_name.*',
#        'tools_jar_path'       => '/usr/lib/jvm/java-7-openjdk-amd64/lib/tools.jar',
#        'java_bin_path'        => '/path/to/java',
#        'trust_store_path'     => '/path/to/trustStore.jks',
#        'trust_store_password' => 'password',
#        'tags'                 => ['env: test', 'sometag: someinfo'],
#      },
#      {
#        'host' => 'localhost',
#        'port' => '9999',
#        'tags' => [],
#      },
#    ]
#  }
#
class datadog_agent::integrations::kafka(
  $servers = [{'host' => 'localhost', 'port' => '9999'}]
) inherits datadog_agent::params {
  include datadog_agent

  validate_array($servers)

  file { "${datadog_agent::params::conf_dir}/kafka.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/kafka.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}