# Class: datadog_agent::integrations::postgres
#
# This class will install the necessary configuration for the postgres integration
#
# Parameters:
#   $host:
#       The host postgres is running on
#   $user
#       The username for the datadog user
#   $password
#       The password for the datadog user
#   $dbname
#       The postgres database name
#   $tags
#       Optional array of tags
#   $tables
#       Track per relation/table metrics. Array of strings.
#       Warning: this can collect lots of metrics per relation
#       (10 + 10 per index)
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::postgres' :
#    host     => 'localhost',
#    dbname   => 'postgres'
#    user     => 'datadog',
#    password => 'some_pass',
#  }
#
#
class datadog_agent::integrations::postgres(
  $host   = 'localhost',
  $port   = '5432',
  $dbname = 'postgres',
  $username = 'datadog',
  $password,
  $tags = [],
  $tables = []
) inherits datadog_agent::params {

  validate_array($tags)
  validate_array($tables)

  file { "${datadog_agent::params::conf_dir}/postgres.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/postgres.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
