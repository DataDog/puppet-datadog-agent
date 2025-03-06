# Class: datadog_agent::integrations::apache
#
# This class will install the necessary configuration for the apache integration
#
# See the sample apache.d/conf.yaml for all available configuration options.
# https://github.com/DataDog/integrations-core/blob/master/apache/datadog_checks/apache/data/conf.yaml.example
#
# Parameters:
#   $url:
#       The URL for apache status URL handled by mod-status.
#       Defaults to http://localhost/server-status?auto
#   $username:
#   $password:
#       If your service uses basic authentication, you can optionally
#       specify a username and password that will be used in the check.
#       Optional.
#   $tags
#       Optional array of tags
#
# Sample Usage:
#
# include 'datadog_agent::integrations::apache'
#
# OR
#
# class { 'datadog_agent::integrations::apache':
#   url      => 'http://example.com/server-status?auto',
#   username => 'status',
#   password => 'hunter1',
# }
#
class datadog_agent::integrations::apache (
  String $url                     = 'http://localhost/server-status?auto',
  Optional[String] $username      = undef,
  Optional[String] $password      = undef,
  Array $tags                     = [],
  Boolean $disable_ssl_validation = false
) inherits datadog_agent::params {
  require datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/apache.d"

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
    content => template('datadog_agent/agent-conf.d/apache.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
