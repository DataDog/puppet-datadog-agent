# Class: datadog_agent::integrations::mesos_master
#
# This class will install the necessary configuration for the mesos integration
#
# See the sample mesos_master.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/mesos_master/datadog_checks/mesos_master/data/conf.yaml.example
#
# Parameters:
#   $url:
#     The URL for Mesos master
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::mesos' :
#     url  => "http://localhost:5050"
#   }
#
class datadog_agent::integrations::mesos_master (
  Integer $mesos_timeout = 10,
  String $url            = 'http://localhost:5050'
) inherits datadog_agent::params {
  require datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/mesos.d"

  file { $dst_dir:
    ensure  => directory,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_directory,
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
  $dst = "${dst_dir}/conf.yaml"

  file { $dst:
    ensure => 'absent',
  }

  $dst_master_dir = "${datadog_agent::params::conf_dir}/mesos_master.d"

  file { $dst_master_dir:
    ensure  => directory,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_directory,
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
  $dst_master = "${dst_master_dir}/conf.yaml"

  file { $dst_master:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_file,
    content => template('datadog_agent/agent-conf.d/mesos_master.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
