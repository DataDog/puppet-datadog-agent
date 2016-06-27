# Class: datadog_agent::integrations::mysql
#
# This class will install the necessary configuration for the mysql integration
#
# Parameters:
#   $host:
#       The host mysql is running on
#   $password
#       The mysql password for the datadog user
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
#
#
class datadog_agent::integrations::mysql(
  $host = 'localhost',
  $password,
  $user = 'datadog',
  $sock = undef,
  $tags = [],
  $replication = '0',
  $galera_cluster = '0',
  $extra_status_metrics = false,
  $extra_innodb_metrics = false,
  $extra_performance_metrics = false,
  $schema_size_metrics = false,
  $disable_innodb_metrics = false,
  ) inherits datadog_agent::params {
  include datadog_agent

  validate_array($tags)

  file { "${datadog_agent::params::conf_dir}/mysql.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/mysql.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}

