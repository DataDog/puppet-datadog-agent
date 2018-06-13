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
#   $ssl
#       Boolean to enable SSL
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
#    ssl      => false,
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
  String $password,
  String $host                   = 'localhost',
  String $dbname                 = 'postgres',
  Variant[String, Integer] $port = '5432',
  String $username               = 'datadog',
  Boolean $ssl                   = false,
  Boolean $use_psycopg2          = false,
  Array[String] $tags            = [],
  Array[String] $tables          = [],
  Hash $custom_metrics           = {},
  Optional[Array] $instances     = undef,
) inherits datadog_agent::params {
  include datadog_agent


  if !$::datadog_agent::agent5_enable {
    $dst = "${datadog_agent::conf6_dir}/postgres.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/postgres.yaml"
  }

  if !$instances and $host {
    $_instances = [{
      'host'           => $host,
      'password'       => $password,
      'dbname'         => $dbname,
      'port'           => $port,
      'username'       => $username,
      'ssl'            => $ssl,
      'use_psycopg2'   => $use_psycopg2,
      'tags'           => $tags,
      'tables'         => $tables,
      'custom_metrics' => $custom_metrics,
    }]
  } elsif !$instances{
    $_instances = []
  } else {
    $_instances = $instances
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
