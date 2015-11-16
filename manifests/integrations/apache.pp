# Class: datadog_agent::integrations::apache
#
# This class will install the necessary configuration for the apache integration
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
  $url                    = 'http://localhost/server-status?auto',
  $username               = undef,
  $password               = undef,
  $tags                   = [],
  $disable_ssl_validation = false
) inherits datadog_agent::params {
  include datadog_agent

  validate_string($url)
  validate_array($tags)
  validate_bool($disable_ssl_validation)

  file { "${datadog_agent::params::conf_dir}/apache.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/apache.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
