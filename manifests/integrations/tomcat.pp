# Class: datadog_agent::integrations::tomcat
#
# This class will install the necessary configuration for the tomcat integration
#
# See the sample tomcat.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/tomcat/datadog_checks/tomcat/data/conf.yaml.example
#
# See the metrics.yaml file for the list of default collected metrics.
# https://github.com/DataDog/integrations-core/blob/master/tomcat/datadog_checks/tomcat/data/metrics.yaml
#
# This check has a limit of 350 metrics per instance. If you require 
# additional metrics, contact Datadog Support at https://docs.datadoghq.com/help/
#
# Parameters:
#   $hostname:
#       The host tomcat is running on. Defaults to 'localhost'
#   $port
#       The JMX port.
#   $jmx_url
#       The JMX URL.
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
#  class { 'datadog_agent::integrations::tomcat':
#    port => 8081,
#  }
#
class datadog_agent::integrations::tomcat (
  String $hostname                    = 'localhost',
  Integer $port                       = 7199,
  Optional[String] $jmx_url           = undef,
  Optional[String] $username          = undef,
  Optional[Any] $password             = undef,
  Optional[String] $java_bin_path     = undef,
  Optional[String] $trust_store_path  = undef,
  Optional[Any] $trust_store_password = undef,
  Hash $tags                          = {},
) inherits datadog_agent::params {
  require datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/tomcat.d"

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
    content => template('datadog_agent/agent-conf.d/tomcat.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
