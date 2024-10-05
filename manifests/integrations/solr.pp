# @summary Install the necessary configuration for the solr integration
#
#
# @param hostname
#   The host solr is running on. Defaults to 'localhost'
# @param port
#   The JMX port.
# @param username
#   The username for connecting to the running JVM. Optional.
# @param password
#   The password for connecting to the running JVM. Optional.
# @param java_bin_path
#   The path to the Java binary. Should be set if the agent cannot find your java executable. Optional.
# @param trust_store_path
#   The path to the trust store. Should be set if ssl is enabled. Optional.
# @param trust_store_password
#   The trust store password. Should be set if ssl is enabled. Optional.
# @param tags
#   Optional hash of tags { env => 'prod' }.
#
#
# @example
#   class { 'datadog_agent::integrations::solr':
#     port => 8081,
#   }
#
class datadog_agent::integrations::solr (
  Stdlib::Host                   $hostname             = 'localhost',
  Stdlib::Port                   $port                 = 7199,
  Optional[String]               $username             = undef,
  Optional[String]               $password             = undef,
  Optional[Stdlib::Absolutepath] $java_bin_path        = undef,
  Optional[Stdlib::Absolutepath] $trust_store_path     = undef,
  Optional[String]               $trust_store_password = undef,
  Hash                           $tags                 = {},
) inherits datadog_agent::params {
  require datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/solr.yaml"
  if $datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/solr.d"
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
    content => template('datadog_agent/agent-conf.d/solr.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
