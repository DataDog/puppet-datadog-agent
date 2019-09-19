# Class: datadog_agent::windows::agent6
#
# This class contains the DataDog agent installation mechanism for Windows
#

class datadog_agent::windows::agent6(
  String $agent_version = $datadog_agent::params::agent_version,
  String $service_ensure = 'running',
  String $baseurl = $datadog_agent::params::agent6_default_repo,
  String $msi_location = 'c:/tmp',
  String $api_key = $datadog_agent::api_key,
  String $hostname = $datadog_agent::host,
  String $service_name = $datadog_agent::service_name_win,
  Array  $tags = $datadog_agent::tags,
  Boolean $service_enable = true,
  Enum['present', 'absent'] $ensure = 'present',
) inherits datadog_agent::params {

  $msi_full_path = "${msi_location}/datadog-agent-6-${agent_version}.amd64.msi"

  if $ensure == 'present' {
    file { $msi_location:
      ensure => directory,
      notify => Exec['downloadmsi']
    }

    exec { 'downloadmsi':
      command  => "Invoke-WebRequest ${baseurl} -outfile ${msi_full_path}",
      onlyif   => "if ((test-path ${msi_full_path}) -eq \$true) {exit 1}",
      provider => powershell,
      notify   => Package[$datadog_agent::params::package_name]
    }

    package { $datadog_agent::params::package_name:
      ensure          => installed,
      provider        => 'windows',
      source          => $msi_full_path,
      install_options => ['/quiet', {'APIKEY' => $api_key, 'HOSTNAME' => $hostname, 'TAGS' => $tags}]
    }

    service { $service_name:
      ensure  => $service_ensure,
      enable  => $service_enable,
      require => Package[$datadog_agent::params::package_name]
    }
  } else {

    file { $msi_location:
      ensure => absent,
      notify => Package[$datadog_agent::params::package_name]
    }

    package { $datadog_agent::params::package_name:
      ensure            => absent,
      provider          => 'windows',
      source            => $msi_full_path,
      uninstall_options => ['/quiet']
    }

  }
}
