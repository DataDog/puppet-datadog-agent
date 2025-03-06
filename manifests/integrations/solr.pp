# Class: datadog_agent::integrations::solr
#
# This class will install the necessary configuration for the solr integration
#
# See the sample solr.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/solr/datadog_checks/solr/data/conf.yaml.example
#
# See the metrics.yaml file for the list of default collected metrics.
# https://github.com/DataDog/integrations-core/blob/master/solr/datadog_checks/solr/data/metrics.yaml
#
# This check has a limit of 350 metrics per instance. If you require 
# additional metrics, contact Datadog Support at https://docs.datadoghq.com/help/
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
class datadog_agent::integrations::solr (
  String $hostname                    = 'localhost',
  Integer $port                       = 7199,
  Optional[String] $username          = undef,
  Optional[Any] $password             = undef,
  Optional[String] $java_bin_path     = undef,
  Optional[String] $trust_store_path  = undef,
  Optional[Any] $trust_store_password = undef,
  Hash $tags                          = {},
) inherits datadog_agent::params {
  require datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/solr.d"

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
    content => template('datadog_agent/agent-conf.d/solr.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
