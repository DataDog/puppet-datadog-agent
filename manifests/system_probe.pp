# Class: datadog_agent::system_probe
#
# This class contains the Datadog agent system probe (NPM) configuration.
# On Windows, install the NPM driver by setting 'windows_npm_install' 
# to 'true on the datadog_agent class.
#

class datadog_agent::system_probe(
  Boolean $enabled = false,
  Boolean $network_enabled = false,
  Optional[String] $log_file = undef,
  Optional[String] $sysprobe_socket = undef,
  Optional[Boolean] $enable_oom_kill = false,
  Optional[Hash] $runtime_security_config = undef,

  Boolean $service_enable = true,
  String $service_ensure = 'running',
  Optional[String] $service_provider = undef,
) inherits datadog_agent::params {


  $sysprobe_config = {
    'system_probe_config' => {
      'enabled' => $enabled,
      'sysprobe_socket' => $sysprobe_socket,
      'log_file' => $log_file,
      'enable_oom_kill' => $enable_oom_kill,
    },
    'network_config' => {
      'enabled' => $network_enabled,
    },
    'runtime_security_config' => $runtime_security_config,
  }

  if $::operatingsystem == 'Windows' {
    file { 'C:/ProgramData/Datadog/system-probe.yaml':
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0640',
      content => template('datadog_agent/system_probe.yaml.erb'),
      require => File['C:/ProgramData/Datadog'],
      notify  => Service[$datadog_agent::params::service_name],
    }

  } else {

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

    file { '/etc/datadog-agent/system-probe.yaml':
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0640',
      content => template('datadog_agent/system_probe.yaml.erb'),
      notify  => Service[$datadog_agent::params::sysprobe_service_name],
      require => File['/etc/datadog-agent'],
    }
  }

}
