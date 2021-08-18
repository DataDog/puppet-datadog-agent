class datadog_agent::security_agent(
  Boolean $enabled = false,
  Optional[String] $socket = undef,

  Boolean $service_enable = true,
  String $service_ensure = 'running',
  Optional[String] $service_provider = undef,

) inherits datadog_agent::params {

  $securityagent_config = {
    'runtime_security_config' => {
      'enabled' => $enabled,
      'socket' =>  $socket,
    },
  }

  if $::operatingsystem == 'Windows' {

    file { 'C:/ProgramData/Datadog/security-agent.yaml':
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0640',
      content => template('datadog_agent/security-agent.yaml.erb'),
      require => File['C:/ProgramData/Datadog'],
    }

  } else {

    if $service_provider {
      service { $datadog_agent::params::securityagent_service_name:
        ensure    => $service_ensure,
        enable    => $service_enable,
        provider  => $service_provider,
        hasstatus => false,
        pattern   => 'dd-agent',
        require   => Package[$datadog_agent::params::package_name],
      }
    } else {
      service { $datadog_agent::params::securityagent_service_name:
        ensure    => $service_ensure,
        enable    => $service_enable,
        hasstatus => false,
        pattern   => 'dd-agent',
        require   => Package[$datadog_agent::params::package_name],
      }
    }

    file { '/etc/datadog-agent/security-agent.yaml':
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0640',
      content => template('datadog_agent/security-agent.yaml.erb'),
      notify  => Service[$datadog_agent::params::securityagent_service_name],
      require => File['/etc/datadog-agent'],
    }
  }

}
