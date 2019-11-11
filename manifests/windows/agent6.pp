# Class: datadog_agent::windows::agent6
#
# This class contains the DataDog agent installation mechanism for Windows
#

class datadog_agent::windows::agent6(
  String $agent_version = $datadog_agent::params::agent_version,
  String $service_ensure = 'running',
  String $baseurl = $datadog_agent::params::agent6_default_repo,
  String $msi_location = 'C:/Windows/temp',
  String $api_key = $datadog_agent::api_key,
  String $hostname = $datadog_agent::host,
  String $service_name = $datadog_agent::service_name_win,
  Array  $tags = $datadog_agent::tags,
  Boolean $service_enable = true,
  Enum['present', 'absent'] $ensure = 'present',
) inherits datadog_agent::params {

  $msi_full_path = "${msi_location}/datadog-agent-6-${agent_version}.amd64.msi"

  if $ensure == 'present' {

    file { 'installer':
      path => $msi_full_path,
      source => $baseurl,
      provider => 'windows',
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
    exec { 'datadog_6_14_fix':
      command => "((New-Object System.Net.WebClient).DownloadFile('https://s3.amazonaws.com/ddagent-windows-stable/scripts/fix_6_14.ps1', $env:temp + '\\fix_6_14.ps1')); &$env:temp\\fix_6_14.ps1",
      provider => powershell,
    }

    package { $datadog_agent::params::package_name:
      ensure            => absent,
      provider          => 'windows',
      uninstall_options => ['/quiet'],
      subscribe         => Exec['datadog_6_14_fix'],
    }

  }
}
