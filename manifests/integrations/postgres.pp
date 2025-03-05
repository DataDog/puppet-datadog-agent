# Class: datadog_agent::integrations::postgres
#
# This class will install the necessary configuration for the postgres integration
#
# See the sample postgres.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/postgres/datadog_checks/postgres/data/conf.yaml.example
#
# Parameters:
#   $password
#       The password for the datadog user
#   $host
#       The host postgres is running on
#   $dbname
#       The postgres database name
#   $port
#       The postgres port number
#   $username
#       The username for the datadog user
#   $ssl
#       This option determines whether or not and with what priority a secure SSL TCP/IP connection
#         is negotiated with the server. There are six modes:
#         - `disable`: Only tries a non-SSL connection.
#         - `allow`: First tries a non-SSL connection; if if fails, tries an SSL connection.
#         - `prefer`: First tries an SSL connection; if it fails, tries a non-SSL connection.
#         - `require`: Only tries an SSL connection. If a root CA file is present, verifies the certificate in
#                      the same way as if verify-ca was specified.
#         - `verify-ca`: Only tries an SSL connection, and verifies that the server certificate is issued by a
#                        trusted certificate authority (CA).
#         - `verify-full`: Only tries an SSL connection and verifies that the server certificate is issued by a
#                          trusted CA and that the requested server host name matches the one in the certificate.
#
#         For a detailed description of how these options work see https://www.postgresql.org/docs/current/libpq-ssl.html
#   $use_psycopg2
#       Boolean to flag connecting to postgres with psycopg2 instead of pg8000.
#       Warning, psycopg2 doesn't support ssl mode.
#   $collect_function_metrics
#       Boolean to enable collecting metrics regarding PL/pgSQL functions from pg_stat_user_functions.
#   $collect_count_metrics
#       Boolean to enable collecting count metrics, default value is True for backward compatibility but they might be slow,
#       suggested value is False.
#   $collect_activity_metrics
#       Boolean to enable collecting metrics regarding transactions from pg_stat_activity, default value is False.
#       Please make sure the user has sufficient privileges to read from pg_stat_activity before enabling this option.
#   $collect_database_size_metrics
#       Boolean to enable collecting database size metrics. Default value is True but they might be slow with large databases
#   $collect_default_database
#       Boolean to enable collecting statistics from the default database 'postgres' in the check metrics, default to false
#   $tags
#       Optional array of tags
#   $tables
#       Track per relation/table metrics. Array of strings.
#       Warning: this can collect lots of metrics per relation
#       (10 + 10 per index)
#   $tags
#       Optional array of tags
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::postgres' :
#    host     => 'localhost',
#    dbname   => 'postgres',
#    username => 'datadog',
#    password => 'some_pass',
#    ssl      => false,
#  }
#
# Hiera Usage:
#
#   datadog_agent::integrations::postgres::instances:
#     - host: 'localhost'
#       dbname: 'postgres'
#       username: 'datadog'
#       password: 'some_pass'
#       ssl: 'allow'
#       custom_metrics:
#         a_custom_query:
#           query: 'select tag_column, %s from table'
#           relation: false
#           metrics:
#             value_column: ["value_column.datadog.tag", "GAUGE"]
#           descriptors:
#           - ["tag_column", "tag_column.datadog.tag"]
#
class datadog_agent::integrations::postgres (
  Optional[String] $password             = undef,
  String $host                           = 'localhost',
  String $dbname                         = 'postgres',
  Variant[String, Integer] $port         = '5432',
  String $username                       = 'datadog',
  String $ssl                            = 'allow',
  Boolean $use_psycopg2                  = false,
  Boolean $collect_function_metrics      = false,
  Boolean $collect_count_metrics         = false,
  Boolean $collect_activity_metrics      = false,
  Boolean $collect_database_size_metrics = false,
  Boolean $collect_default_database      = false,
  Array[String] $tags                    = [],
  Array[String] $tables                  = [],
  Optional[Array] $instances             = undef,
) inherits datadog_agent::params {
  require datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/postgres.yaml"
  if $datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/postgres.d"
    file { $legacy_dst:
      ensure => 'absent',
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name],
    }
    $dst = "${dst_dir}/conf.yaml"
  } else {
    $dst = $legacy_dst
  }

  if !$instances and $host {
    $_instances = [{
        'host'                          => $host,
        'password'                      => $password,
        'dbname'                        => $dbname,
        'port'                          => $port,
        'username'                      => $username,
        'ssl'                           => $ssl,
        'use_psycopg2'                  => $use_psycopg2,
        'tags'                          => $tags,
        'tables'                        => $tables,
        'collect_function_metrics'      => $collect_function_metrics,
        'collect_count_metrics'         => $collect_count_metrics,
        'collect_activity_metrics'      => $collect_activity_metrics,
        'collect_database_size_metrics' => $collect_database_size_metrics,
        'collect_default_database'      => $collect_default_database,
    }]
  } elsif !$instances {
    $_instances = []
  } else {
    $_instances = $instances
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/postgres.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
