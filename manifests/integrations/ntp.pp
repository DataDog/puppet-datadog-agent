# Class: datadog_agent::integrations::ntp
#
# This class will enable ntp check
#
# Parameters: 
#   $offset:
#        Offset threshold for a critical alert. Defaults to 600.
# 
#	Sample Usage:
# 
#  class { 'datadog_agent::integrations::ntp' :
#    offset     => 600,
#  }
#

class datadog_agent::integrations::ntp(
	$offset = 600,
) inherits datadog_agent::params {
	
  file { "${datadog_agent::params::conf_dir}/ntp.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/ntp.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}