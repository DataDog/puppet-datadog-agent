# Class: datadog_agent::integrations::mysql
#
# This class will install the necessary configuration for the mysql integration
#
# Parameters:
#   $password
#       The mysql password for the datadog user
#   $host:
#       The host mysql is running on
#   $user
#       The mysql user for the datadog user
#   $sock
#       Connect mysql via unix socket
#   $tags
#       Optional array of tags
#   $replication
#       replication option
#   $galera_cluster
#       galera cluster option
#   $extra_status_metrics
#       extra status metrics
#   $extra_innodb_metrics
#       extra innodb metrics
#   $extra_performance_metrics
#       extra performance metrics, query run time, 95th precentile avg
#   $schema_size_metrics
#       schema size metrics
#   $disable_innodb_metrics
#       disable innodb metrics, used with older versions of MySQL without innodb engine support.
# Sample Usage:
#
#  class { 'datadog_agent::integrations::mysql' :
#    host     => 'localhost',
#    password => 'some_pass',
#    user     => 'datadog'
#  }
# Sample Usage (Instance):
#  class { 'datadog_agent::integrations::mysql' :
#    instances => [{
#      host                      => 'localhost',
#      password                  => 'mypassword',
#      user                      => 'datadog',
#      port                      => '3306',
#      tags                      => ['instance:mysql1'],
#      replication               => '0',
#      galera_cluster            => '0',
#      extra_status_metrics      => 'true',
#      extra_innodb_metrics      => 'true',
#      extra_performance_metrics => 'true',
#      schema_size_metrics       => 'true', 
#      disable_innodb_metrics    => 'false',
#    }
#  }
#
#
class datadog_agent::integrations::mysql(
  String $password,
  String $host                       = 'localhost',
  String $user                       = 'datadog',
  Variant[String, Integer] $port     = 3306,
  Optional[String] $sock             = undef,
  Array $tags                        = [],
  $replication                       = '0',
  $galera_cluster                    = '0',
  Boolean $extra_status_metrics      = false,
  Boolean $extra_innodb_metrics      = false,
  Boolean $extra_performance_metrics = false,
  Boolean $schema_size_metrics       = false,
  Boolean $disable_innodb_metrics    = false,
  Optional[Array] $instances         = undef,
  ) inherits datadog_agent::params {
  include datadog_agent

  validate_legacy('Optional[String]', 'validate_string', $sock)
  validate_legacy('Array', 'validate_array', $tags)

  if !$instances and $host {
    $_instances = [{
      'host'                      => $host,
      'password'                  => $password,
      'user'                      => $user,
      'port'                      => $port,
      'sock'                      => $sock,
      'tags'                      => $tags,
      'replication'               => $replication,
      'galera_cluster'            => $galera_cluster,
      'extra_status_metrics'      => $extra_status_metrics,
      'extra_innodb_metrics'      => $extra_innodb_metrics,
      'extra_performance_metrics' => $extra_performance_metrics,
      'schema_size_metrics'       => $schema_size_metrics,
      'disable_innodb_metrics'    => $disable_innodb_metrics,
    }]
  } elsif !$instances{
    $_instances = []
  } else {
    $_instances = $instances
  }

  if !$::datadog_agent::agent5_enable {
    $dst = "${datadog_agent::conf6_dir}/mysql.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/mysql.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/mysql.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}

