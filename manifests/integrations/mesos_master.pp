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

  dst = "${datadog_agent::conf_dir}/mesos.yaml"
  if $::datadog_agent::agent6_enable {
    dst = "${datadog_agent::conf6_dir}/mesos.yaml"
  }

  file { "${dst}":
    ensure => 'absent'
  }

  dst_master = "${datadog_agent::conf_dir}/mesos_master.yaml"
  if $::datadog_agent::agent6_enable {
    dst_master = "${datadog_agent::conf6_dir}/mesos_master.yaml"
  }

  file { "${dst_master}":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0644',
    content => template('datadog_agent/agent-conf.d/mesos_master.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
