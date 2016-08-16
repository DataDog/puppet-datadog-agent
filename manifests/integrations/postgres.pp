# Class: datadog_agent::integrations::postgres
#
# lint:ignore:80chars
# This class will install the necessary configuration for the postgres integration
#
# Parameters:
#   $host:
#       The host postgres is running on
#   $dbname
#       The postgres database name
#   $port
#       The postgres port number
#   $username
#       The username for the datadog user
#   $password
#       The password for the datadog user
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
#    username => 'datadog',
#    password => 'some_pass',
#  }
#
#
class datadog_agent::integrations::postgres(
  $host   = 'localhost',
  $dbname = 'postgres',
  $port   = '5432',
  $username = 'datadog',
  $password,
  $tags = [],
  $tables = []
) inherits datadog_agent::params { # lint:ignore:class_inherits_from_params_class

  validate_array($tags)
  validate_array($tables)

  file { "${datadog_agent::params::conf_dir}/postgres.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/postgres.yaml.erb'),
    require => Class['datadog_agent'],
    notify  => Service[$datadog_agent::params::service_name],
  }
# lint:endignore
}
