# @summary Enable ntp check
#
#
# @param offset_threshold
#   Offset threshold for a critical alert. Defaults to 600.
# @param host
#   ntp server to use for ntp check
# @param port
# @param version
# @param timeout
#
#
#
# @example
#   class { 'datadog_agent::integrations::ntp' :
#     offset_threshold     => 60,
#     host                 => 'pool.ntp.org',
#   }
#
class datadog_agent::integrations::ntp (
  Integer                $offset_threshold = 60,
  Optional[Stdlib::Host] $host             = undef,
  Optional[Stdlib::Port] $port             = undef,
  Optional[String]       $version          = undef,
  Optional[Integer]      $timeout          = undef,
) inherits datadog_agent::params {
  require datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/ntp.yaml"
  if $datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/ntp.d"
    file { $legacy_dst:
      ensure => 'absent',
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name],
    }
    $dst = "${dst_dir}/conf.yaml"
  } else {
    $dst = $legacy_dst
  }

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
