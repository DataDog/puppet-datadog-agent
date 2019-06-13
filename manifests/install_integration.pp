define datadog_agent::install_integration (
  Enum['present', 'absent'] $ensure           = 'present',
  String                    $integration_name = undef,
  String                    $version          = undef,
){

  include datadog_agent

  if $ensure == 'present' {
    $command = 'install'
  } else {
    $command = 'remove'
  }

  exec { "${command} ${integration_name}==${version}":
    command => "/opt/datadog-agent/bin/agent/agent integration ${command} ${integration_name}==${version}",
    user    => 'dd-agent',
    require => Package[$datadog_agent::params::package_name],
  }

}
