class datadog_agent::system_probe(
  Boolean $enabled = false,
  Optional[String] $log_file = undef,
  Optional[String] $sysprobe_socket = undef,
  Optional[Boolean] $enable_oom_kill = false,

  Boolean $service_enable = true,
  String $service_ensure = 'running',
  Optional[String] $service_provider = undef,
) inherits datadog_agent::params {

  if $::operatingsystem == 'Windows' {
    # Datadog does not currently support Windows and macOS platforms for Network Performance Monitoring
    fail('Network performance monitoring is only supported on Linux.')
  }

  if $service_provider {
    service { $datadog_agent::params::sysprobe_service_name:
      ensure    => $service_ensure,
      enable    => $service_enable,
      provider  => $service_provider,
      hasstatus => false,
      pattern   => 'dd-agent',
      require   => Package[$datadog_agent::params::package_name],
    }
  } else {
    service { $datadog_agent::params::sysprobe_service_name:
      ensure    => $service_ensure,
      enable    => $service_enable,
      hasstatus => false,
      pattern   => 'dd-agent',
      require   => Package[$datadog_agent::params::package_name],
    }
  }

  $sysprobe_config = {
    'system_probe_config' => {
      'enabled' => $enabled,
      'sysprobe_socket' => $sysprobe_socket,
      'log_file' => $log_file,
      'enable_oom_kill' => $enable_oom_kill,
    }
  }

  file { '/etc/datadog-agent/system-probe.yaml':
    owner   => $datadog_agent::params::dd_user,
    group   => 'dd-agent',
    mode    => '0640',
    content => template('datadog_agent/system_probe.yaml.erb'),
    notify  => Service[$datadog_agent::params::sysprobe_service_name],
    require => File['/etc/datadog-agent'],
  }

}
