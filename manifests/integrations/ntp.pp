# Class: datadog_agent::integrations::ntp
#
# This class will enable ntp check
#
# Parameters:
#   $offset_threshold:
#        Offset threshold for a critical alert. Defaults to 600.
#
#   $host:
#        ntp server to use for ntp check
#
#   $port
#
#   $version
#
#   $timeout
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::ntp' :
#    offset_threshold     => 60,
#    host                 => 'pool.ntp.org',
#  }
#
# lint:ignore:80chars
class datadog_agent::integrations::ntp(
  $offset_threshold = 60,
  $host             = undef,
  $port             = undef,
  $version          = undef,
  $timeout          = undef,
) inherits datadog_agent::params { # lint:ignore:class_inherits_from_params_class

  file { "${datadog_agent::params::conf_dir}/ntp.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/ntp.yaml.erb'),
    require => [Class['datadog_agent'],Package[$datadog_agent::params::package_name]],
    notify  => Service[$datadog_agent::params::service_name]
  }
# lint:endignore
}
