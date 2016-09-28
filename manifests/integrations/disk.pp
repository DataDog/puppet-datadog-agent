# Class: datadog_agent::integrations::ntp
#
# This class will enable ntp check
#
# Parameters:
#   $offset_threshold:
#        Offset threshold for a critical alert. Defaults to 600.
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::ntp' :
#    offset_threshold     => 60,
#  }
#

class datadog_agent::integrations::disk(
  $offset_threshold = 60,
) inherits datadog_agent::params {

  file { "${datadog_agent::params::conf_dir}/disk.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/disk.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
