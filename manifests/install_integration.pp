define datadog_agent::install_integration (
  Enum['present', 'absent'] $ensure           = 'present',
  String                    $integration_name = undef,
  String                    $version          = undef,
){

  include datadog_agent

  if $ensure == 'present' {
    exec { "install ${integration_name}==${version}":
      command => "/opt/datadog-agent/bin/agent/agent integration install ${integration_name}==${version}",
      user    => 'dd-agent',
      unless  => "/opt/datadog-agent/bin/agent/agent integration freeze | grep ${integration_name}==${version}",
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name],
    }
  } else {
    exec { "remove ${integration_name}==${version}":
      command => "/opt/datadog-agent/bin/agent/agent integration remove ${integration_name}==${version}",
      user    => 'dd-agent',
      onlyif  => "/opt/datadog-agent/bin/agent/agent integration freeze | grep ${integration_name}==${version}",
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name],
    }
  }

}
