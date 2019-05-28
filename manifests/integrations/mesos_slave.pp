# Class: datadog_agent::integrations::mesos_slave
#
# This class will install the necessary configuration for the mesos slave integration
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
class datadog_agent::integrations::mesos_slave(
  $mesos_timeout = 10,
  $url = 'http://localhost:5051'
) inherits datadog_agent::params {

  $legacy_dst = "${datadog_agent::conf_dir}/mesos_slave.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/mesos_slave.d"
    file { $legacy_dst:
      ensure => 'absent'
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0755',
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name]
    }
    $dst = "${dst_dir}/conf.yaml"
  } else {
    $dst = $legacy_dst
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0644',
    content => template('datadog_agent/agent-conf.d/mesos_slave.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
