# Class: datadog_agent::integrations::solr
#
# This class will install the necessary configuration for the solr integration
#
# Parameters:
#   $hostname:
#       The host solr is running on. Defaults to 'localhost'
#   $port
#       The JMX port.
#   $username
#       The username for connecting to the running JVM. Optional.
#   $password
#       The password for connecting to the running JVM. Optional.
#   $java_bin_path
#       The path to the Java binary. Should be set if the agent cannot find your java executable. Optional.
#   $trust_store_path
#       The path to the trust store. Should be set if ssl is enabled. Optional.
#   $trust_store_password
#       The trust store password. Should be set if ssl is enabled. Optional.
#   $tags
#       Optional hash of tags { env => 'prod' }.
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::solr':
#    port => 8081,
#  }
#
class datadog_agent::integrations::solr(
  $hostname             = 'localhost',
  $port                 = 7199,
  $username             = undef,
  $password             = undef,
  $java_bin_path        = undef,
  $trust_store_path     = undef,
  $trust_store_password = undef,
  $tags                 = {},
) inherits datadog_agent::params {
  include datadog_agent

  $legacy_dst = "${datadog_agent::conf_dir}/solr.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/solr.d"
    file { $legacy_dst:
      ensure => 'absent'
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0775',
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
    mode    => '0660',
    content => template('datadog_agent/agent-conf.d/solr.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }

}
