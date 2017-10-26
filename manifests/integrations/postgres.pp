# Class: datadog_agent::integrations::postgres
#
# This class will install the necessary configuration for the postgres integration
#
# Parameters:
#   $password
#       The password for the datadog user
#   $host:
#       The host postgres is running on
#   $dbname
#       The postgres database name
#   $port
#       The postgres port number
#   $username
#       The username for the datadog user
#   $use_psycopg2
#       Boolean to flag connecting to postgres with psycopg2 instead of pg8000.
#       Warning, psycopg2 doesn't support ssl mode.
#   $tags
#       Optional array of tags
#   $tables
#       Track per relation/table metrics. Array of strings.
#       Warning: this can collect lots of metrics per relation
#       (10 + 10 per index)
#   $tags
#       Optional array of tags
#   $custom_metrics
#       A hash of custom metrics with the following keys - query, metrics,
#       relation, descriptors. Refer to this guide for details on those fields:
#       https://help.datadoghq.com/hc/en-us/articles/208385813-Postgres-custom-metric-collection-explained
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::postgres' :
#    host     => 'localhost',
#    dbname   => 'postgres'
#    username => 'datadog',
#    password => 'some_pass',
#    custom_metrics => {
#      a_custom_query => {
#        query => "select tag_column, %s from table",
#        relation => false,
#        metrics => {
#          value_column => ["value_column.datadog.tag", "GAUGE"]
#        },
#        descriptors => [
#          ["tag_column", "tag_column.datadog.tag"]
#        ]
#      }
#    }
#  }
#
#
class datadog_agent::integrations::postgres(
  $password,
  $host   = 'localhost',
  $dbname = 'postgres',
  $port   = '5432',
  $username = 'datadog',
  $use_psycopg2 = false,
  $tags = [],
  $tables = [],
  $custom_metrics = {},
) inherits datadog_agent::params {
  include datadog_agent

  validate_array($tags)
  validate_array($tables)
  validate_bool($use_psycopg2)

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/postgres.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/postgres.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/postgres.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }

  create_resources('datadog_agent::integrations::postgres_custom_metric', $custom_metrics)
}
