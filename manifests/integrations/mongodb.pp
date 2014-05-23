# Class: datadog::integrations::mongodb
#
# This class will install the necessary configuration for the mongodb integration
#
# Parameters:
# $db_admin_user
#    The mongodb user with administrative privileges to add a new user
#
# $db_admin_password
#    The mongodb password for the user with administrative privileges to add a new user#
#
# $db_user
#    The mongodb user that will be used for reading database metrics
#
# $db_password
#    The mongodb password for the user for reading database metrics
#
# $db_port
#    The port that the mongodb instance is running on
#
# $tags
#    Tags to be sent with any metrics from this database
#
# $mongodb_servers
#    The mongo URI for the mongo database instance
#
# Sample Usage:
#
#  class { 'datadog::integrations::mongodb' :
#    db_user     => 'datadog',
#    db_password => 'some_pass',
#    mongodb_server     => 'mongodb://datadog:some_pass@localhost:27017'
#  }
#
#
class datadog::integrations::mongodb(
  $db_admin_user = '',
  $db_admin_password = '',
  $db_user = 'datadog',
  $db_password,
  $db_port = 27017,
  $tags = [],
  $mongodb_server
) inherits datadog::params {

  package { $mongodb_int_package :
    ensure => installed,
  }

  file {'mongo_user_script':
    ensure => file,
    mode => 755,
    path => '/root/datadog_mongo_user.py',
    content => template('datadog/mongo_user_add.py.erb')
  }

  exec { 'mongodb_add_datadog_user':
    command => '/root/datadog_mongo_user.py',
    require => [Package[$mongodb_int_package], File['mongo_user_script']]
  }

  file { "${conf_dir}/mongo.yaml":
    ensure  => file,
    owner   => $dd_user,
    group   => $dd_group,
    mode    => 0644,
    content => template('datadog/mongo.yaml.erb'),
    require => Exec['mongodb_add_datadog_user'],
    notify  => Service[$service_name]
  }
}
