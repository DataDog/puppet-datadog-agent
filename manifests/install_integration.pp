define datadog_agent::install_integration (
  Enum['present', 'absent'] $ensure           = 'present',
  String                    $integration_name = undef,
  String                    $version          = undef,
  Boolean                   $third_party      = false,
){

  include datadog_agent

  if $ensure == 'present' {

    if $third_party {
      $install_cmd = 'install --third-party'
    } else {
      $install_cmd = 'install'
    }

    exec { "install ${integration_name}==${version}":
      command => "${datadog_agent::params::agent_binary} integration ${install_cmd} ${integration_name}==${version}",
      user    => $datadog_agent::dd_user,
      unless  => "${datadog_agent::params::agent_binary} integration freeze | grep ${integration_name}==${version}",
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name],
    }
  } else {
    exec { "remove ${integration_name}==${version}":
      command => "${datadog_agent::params::agent_binary} integration remove ${integration_name}==${version}",
      user    => $datadog_agent::dd_user,
      onlyif  => "${datadog_agent::params::agent_binary} integration freeze | grep ${integration_name}==${version}",
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name],
    }
  }

}
