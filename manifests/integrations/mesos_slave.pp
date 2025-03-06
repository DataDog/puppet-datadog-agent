# Class: datadog_agent::integrations::mesos_slave
#
# This class will install the necessary configuration for the mesos slave integration
#
# See the sample mesos_slave.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/mesos_slave/datadog_checks/mesos_slave/data/conf.yaml.example
#
# Parameters:
#   $url:
#     The URL for Mesos slave
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::mesos' :
#     url  => "http://localhost:5051"
#   }
#
class datadog_agent::integrations::mesos_slave (
  Integer $mesos_timeout = 10,
  String $url            = 'http://localhost:5051'
) inherits datadog_agent::params {
  $dst_dir = "${datadog_agent::params::conf_dir}/mesos_slave.d"

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
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_file,
    content => template('datadog_agent/agent-conf.d/mesos_slave.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
