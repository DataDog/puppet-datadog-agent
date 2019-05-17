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
  $host = 'localhost',
  Variant[String[1], Integer] $port = 9999,
  Optional[String[1]] $username = undef,
  Optional[String[1]] $password = undef,
  Optional[String[1]] $process_name_regex = undef,
  Optional[String[1]] $tools_jar_path = undef,
  Optional[String[1]] $java_bin_path = undef,
  Optional[String[1]] $trust_store_path = undef,
  Optional[String[1]] $trust_store_password = undef,
  Optional[Hash[String[1], String[1]]] $tags = undef,
  Optional[Array[Hash[String[1], Data]]] $instances = undef,
) inherits datadog_agent::params {
  include datadog_agent

  if !$instances and $host and $port {
    $servers = [{
      'host'                      => $host,
      'port'                      => $port,
      'username'                  => $username,
      'password'                  => $password,
      'process_name_regex'        => $process_name_regex,
      'tools_jar_path'            => $tools_jar_path,
      'java_bin_path'             => $java_bin_path,
      'trust_store_path'          => $trust_store_path,
      'trust_store_password'      => $trust_store_password,
      'tags'                      => $tags,
    }]
  } elsif !$instances{
    $servers = []
  } else {
    $servers = $instances
  }

  $legacy_dst = "${datadog_agent::conf_dir}/kafka.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/kafka.d"
    file { $legacy_dst:
      ensure => 'absent'
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0755',
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
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/kafka.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
