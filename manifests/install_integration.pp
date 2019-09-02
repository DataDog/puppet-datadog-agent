define datadog_agent::install_integration (
  Enum['present', 'absent'] $ensure           = 'present',
  String                    $integration_name = undef,
  String                    $version          = undef,
){

  include datadog_agent

  if $::operatingsystem == 'Windows' {
    $agent_binary = 'C:/Program Files/Datadog/Datadog Agent/embedded/agent.exe'
  } else {
    $agent_binary = '/opt/datadog-agent/bin/agent/agent'
  }

  if $ensure == 'present' {
    exec { "install ${integration_name}==${version}":
      command => "${agent_binary} integration install ${integration_name}==${version}",
      user    => $datadog_agent::dd_user,
      unless  => "${agent_binary} integration freeze | grep ${integration_name}==${version}",
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name],
    }
  } else {
    exec { "remove ${integration_name}==${version}":
      command => "${agent_binary} integration remove ${integration_name}==${version}",
      user    => $datadog_agent::dd_user,
      onlyif  => "${agent_binary} integration freeze | grep ${integration_name}==${version}",
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name],
    }
  }

}
