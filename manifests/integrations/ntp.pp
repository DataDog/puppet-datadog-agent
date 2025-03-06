# Class: datadog_agent::integrations::ntp
#
# This class will enable ntp check
#
# See the sample ntp.d/conf.yaml for all available configuration options
# https://github.com/DataDog/datadog-agent/blob/main/cmd/agent/dist/conf.d/ntp.d/conf.yaml.default
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
class datadog_agent::integrations::ntp (
  Integer $offset_threshold  = 60,
  Optional[String] $host     = undef,
  Optional[Integer] $port    = undef,
  Optional[String] $version  = undef,
  Optional[Integer] $timeout = undef,
) inherits datadog_agent::params {
  require datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/ntp.d"

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
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/ntp.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
