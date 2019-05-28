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

class datadog_agent::integrations::ntp(
  $offset_threshold = 60,
  $host             = undef,
  $port             = undef,
  $version          = undef,
  $timeout          = undef,
) inherits datadog_agent::params {
  include datadog_agent

  $legacy_dst = "${datadog_agent::conf_dir}/ntp.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/ntp.d"
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
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/ntp.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
