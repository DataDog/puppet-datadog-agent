# Class: datadog_agent::integrations::activemq_xml
#
# This class will install the necessary configuration for the activemq_xml integration
#
# Parameters:
#   $password
#       The password for the datadog user
#   $host
#       The host activemq_xml is running on
#   $dbname
#       The activemq_xml database name
#   $port
#       The activemq_xml port number
#   $username
#       The username for the datadog user
#   $ssl
#       Boolean to enable SSL
#   $use_psycopg2
#       Boolean to flag connecting to activemq_xml with psycopg2 instead of pg8000.
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
#       Boolean to enable collecting statistics from the default database 'activemq_xml' in the check metrics, default to false
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
#       https://help.datadoghq.com/hc/en-us/articles/208385813-activemq_xml-custom-metric-collection-explained
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::activemq_xml' :
#    host     => 'localhost',
#    dbname   => 'activemq_xml'
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
# Hiera Usage:
#
#   datadog_agent::integrations::activemq_xml::instances:
#     - host: 'localhost'
#       dbname: 'activemq_xml'
#       username: 'datadog'
#       password: 'some_pass'
#       ssl: false
#       custom_metrics:
#         a_custom_query:
#           query: 'select tag_column, %s from table'
#           relation: false
#           metrics:
#             value_column: ["value_column.datadog.tag", "GAUGE"]
#           descriptors:
#           - ["tag_column", "tag_column.datadog.tag"]
#
class datadog_agent::integrations::activemq_xml(
  String $url                                   = 'http://localhost:8161',
  Boolean $supress_errors                       = false,
  Optional[String] $username                    = undef,
  Optional[String] $password                    = undef,
  Optional[Array[String]] $detailed_queues      = [],
  Optional[Array[String]] $detailed_topics      = [],
  Optional[Array[String]] $detailed_subscribers = [],
  Optional[Array] $instances                    = undef,
) inherits datadog_agent::params {
  include datadog_agent

  $legacy_dst = "${datadog_agent::conf_dir}/activemq_xml.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst = "${datadog_agent::conf6_dir}/activemq_xml.d/conf.yaml"
    file { $legacy_dst:
      ensure => 'absent'
    }
  } else {
    $dst = $legacy_dst
  }

  if !$instances and $url {
    $_instances = [{
      'url'                  => $url,
      'username'             => $username,
      'password'             => $password,
      'supress_errors'       => $supress_errors,
      'detailed_queues'      => $detailed_queues,
      'detailed_topics'      => $detailed_topics,
      'detailed_subscribers' => $detailed_subscribers,
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
    content => template('datadog_agent/agent-conf.d/activemq_xml.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
