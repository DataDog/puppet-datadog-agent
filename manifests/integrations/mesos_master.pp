# Class: datadog_agent::integrations::mesos_master
#
# This class will install the necessary configuration for the mesos integration
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
class datadog_agent::integrations::mesos_master(
  $mesos_timeout = 10,
  $url = 'http://localhost:5050'
) inherits datadog_agent::params {
  include datadog_agent

  if $::datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/mesos.d"

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name]
    }
    $dst = "${dst_dir}/conf.yaml"
  } else {
    $dst = "${datadog_agent::params::legacy_conf_dir}/mesos.yaml"
  }

  file { $dst:
    ensure => 'absent'
  }

  $legacy_dst_master = "${datadog_agent::params::legacy_conf_dir}/mesos_master.yaml"
  if $::datadog_agent::_agent_major_version > 5 {
    $dst_master_dir = "${datadog_agent::params::conf_dir}/mesos_master.d"
    file { $legacy_dst_master:
      ensure => 'absent'
    }

    file { $dst_master_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name]
    }
    $dst_master = "${dst_master_dir}/conf.yaml"
  } else {
    $dst_master = $legacy_dst_master
  }

  file { $dst_master:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_file,
    content => template('datadog_agent/agent-conf.d/mesos_master.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
