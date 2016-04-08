# Class: datadog_agent::integrations::pgbouncer
#
# This class will install the necessary configuration for the pgbouncer integration
#
# Parameters:
#   $host:
#       The host pgbouncer is listening on
#   $port
#       The pgbouncer port number
#   $username
#       The username for the datadog user
#   $password
#       The password for the datadog user
#   $tags
#       Optional array of tags
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::pgbouncer' :
#    host     => 'localhost',
#    username => 'datadog',
#    port     => '6432',
#    password => 'some_pass',
#  }
#
#
class datadog_agent::integrations::pgbouncer(
  $host   = 'localhost',
  $port   = '6432',
  $username = 'datadog',
  $password,
  $tags = [],
) inherits datadog_agent::params {

  validate_array($tags)

  file { "${datadog_agent::params::conf_dir}/pgbouncer.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/pgbouncer.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
