# Class: datadog_agent::integrations::apache
#
# This class will install the necessary configuration for the apache integration
#
# Parameters:
#   $instances
#       A hash in the format of the YAML instance.
#   $url: DEPRECATED
#       The URL for apache status URL handled by mod-status.
#       Defaults to http://localhost/server-status?auto
#   $username: DEPRECATED
#   $password: DEPRECATED
#       If your service uses basic authentication, you can optionally
#       specify a username and password that will be used in the check.
#       Optional.
#   $tags: DEPRECATED
#       Optional array of tags

class datadog_agent::integrations::apache (
  $instances,
  $init_config = undef,
  $url       = 'http://localhost/server-status?auto',
  $username  = undef,
  $password  = undef,
  $tags      = []
) inherits datadog_agent::params {

  validate_hash($instances)

  if $url
     or $username
     or $password
     or $tags
  {
    warning("Deprecation: using a fixed var instead of $instances. See https://github.com/DataDog/puppet-datadog-agent/wiki/NewManifests")
  }

  validate_string($url)
  validate_array($tags)

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
