# Class: datadog_agent::integrations::tomcat
#
# This class will install the necessary configuration for the tomcat integration
#
# Parameters:
#   $hostname:
#       The host tomcat is running on. Defaults to 'localhost'
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
#  class { 'datadog_agent::integrations::tomcat':
#    port => 8081,
#  }
#
class datadog_agent::integrations::tomcat(
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


  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/tomcat.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/tomcat.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/tomcat.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }

}
