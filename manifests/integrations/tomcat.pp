# Class: datadog_agent::integrations::tomcat
#
# This class will install the necessary configuration for the tomcat integration
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
  $hostname             = 'localhost',
  $port                 = 7199,
  $jmx_url              = undef,
  $username             = undef,
  $password             = undef,
  $instance_name        = undef,
  $service_name         = undef,
  $application_name     = undef,
  $tomcat_conf_dir      = undef,
  $java_bin_path        = undef,
  $trust_store_path     = undef,
  $trust_store_password = undef,
  $max_returned_metrics = undef,
  $tags                 = {},
) inherits datadog_agent::params {

  $dst_dir = "${datadog_agent::params::conf_dir}/tomcat.d"

  file { $dst_dir:
    ensure  => directory,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_directory,
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }

  $dst = "${dst_dir}/conf.yaml"


  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/tomcat.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }

  file { "${tomcat_conf_dir}/log4j2.xml":
    ensure => file,
    owner => root,
    group => tomcat,
    mode => '0644',
    content => template('datadog_agent/log4j2.xml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
