# @summary Install the necessary configuration for the mysql integration
#
#
# @param host
#       The host mysql is running on
# @param user
#       The mysql user for the datadog user
# @param port
# @param password
#       The mysql password for the datadog user
# @param sock
#       Connect mysql via unix socket
# @param tags
#       Optional array of tags
# @param replication
#       replication option
# @param galera_cluster
#       galera cluster option
# @param extra_status_metrics
#       extra status metrics
# @param extra_innodb_metrics
#       extra innodb metrics
# @param extra_performance_metrics
#       extra performance metrics, query run time, 95th precentile avg
# @param schema_size_metrics
#       schema size metrics
# @param disable_innodb_metrics
#       disable innodb metrics, used with older versions of MySQL without innodb engine support.
# @param dbm
#       Database Monitoring for Application Performance Monitoring (APM)
# @param queries
#       Custom metrics based on MySQL query
# @param instances
# @param logs
#
#
# @example
#   class { 'datadog_agent::integrations::mysql' :
#     host     => 'localhost',
#     password => 'some_pass',
#     user     => 'datadog'
#   }
#
# @example
#   class { 'datadog_agent::integrations::mysql' :
#     instances => [{
#       host                      => 'localhost',
#       password                  => 'mypassword',
#       user                      => 'datadog',
#       port                      => '3306',
#       tags                      => ['instance:mysql1'],
#       replication               => '0',
#       galera_cluster            => '0',
#       extra_status_metrics      => 'true',
#       extra_innodb_metrics      => 'true',
#       extra_performance_metrics => 'true',
#       schema_size_metrics       => 'true',
#       disable_innodb_metrics    => 'false',
#       dbm                       => 'false',
#       queries                   => [
#         {
#           query  => 'SELECT TIMESTAMPDIFF(second,MAX(create_time),NOW()) as last_accessed FROM requests',
#           metric => 'app.seconds_since_last_request',
#           type   => 'gauge',
#           field  => 'last_accessed',
#         },
#       ],
#     }
#   }
#
class datadog_agent::integrations::mysql (
  String $host                             = 'localhost',
  String $user                             = 'datadog',
  Variant[String, Integer] $port           = 3306,
  Optional[String] $password               = undef,
  Optional[String] $sock                   = undef,
  Array $tags                              = [],
  String $replication                      = '0',
  String $galera_cluster                   = '0',
  Boolean $extra_status_metrics            = false,
  Boolean $extra_innodb_metrics            = false,
  Boolean $extra_performance_metrics       = false,
  Boolean $schema_size_metrics             = false,
  Boolean $disable_innodb_metrics          = false,
  Optional[Boolean] $dbm                   = undef,
  Array $queries                           = [],
  Optional[Array] $instances               = undef,
  Array $logs                              = [],
) inherits datadog_agent::params {
  require datadog_agent

  if ($host == undef and $sock == undef) or ($host != undef and $port == undef and $sock == undef) {
    fail('invalid MySQL configuration')
  }

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
        'dbm'                       => $dbm,
        'queries'                   => $queries,
    }]
  } elsif !$instances {
    $_instances = []
  } else {
    $_instances = $instances
  }

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/mysql.yaml"
  if $datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/mysql.d"
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

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/mysql.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
