# Class: datadog::integrations::mysql
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
#   $tags
#       Optional array of tags
#   $replication
#       replication option
#   $galera_cluster
#       galera cluster option
#
# Sample Usage:
#
#  class { 'datadog::integrations::mysql' :
#    host     => 'localhost',
#    password => 'some_pass',
#    user     => 'datadog'
#  }
#
#
class datadog::integrations::mysql(
  $host,
  $password,
  $user = 'datadog',
  $tags = [],
  $replication = '0',
  $galera_cluster = '0'
) inherits datadog::params {

  package { $mysql_int_package :
    ensure => installed,
  }

  file { "${conf_dir}/mysql.yaml":
    ensure  => file,
    owner   => $dd_user,
    group   => $dd_group,
    mode    => 0644,
    content => template('datadog/mysql.yaml.erb'),
    require => Package[$mysql_int_package],
    notify  => Service[$service_name]
  }
}
