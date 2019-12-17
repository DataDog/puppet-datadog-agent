# Class: datadog_agent::windows
#
# This class contains the DataDog agent installation mechanism for Windows
#

class datadog_agent::windows(
  Integer $agent_major_version = $datadog_agent::params::default_agent_major_version,
  String $agent_version = $datadog_agent::params::agent_version,
  String $service_ensure = 'running',
  Optional[String] $agent_repo_uri = undef,
  String $msi_location = 'C:/Windows/temp',
  String $api_key = $datadog_agent::api_key,
  String $hostname = $datadog_agent::host,
  String $service_name = $datadog_agent::service_name_win,
  Array  $tags = $datadog_agent::tags,
  Boolean $service_enable = true,
  Enum['present', 'absent'] $ensure = 'present',
) inherits datadog_agent::params {

  $msi_full_path = "${msi_location}/datadog-agent-${agent_major_version}-${agent_version}.amd64.msi"

  if ($agent_repo_uri != undef) {
    $baseurl = $agent_repo_uri
  } else {
    $baseurl = 'https://s3.amazonaws.com/ddagent-windows-stable/'
  }

  if $agent_version == 'latest' {
    $msi_source = "${baseurl}datadog-agent-${agent_major_version}-latest.amd64.msi"
  } else {
    $msi_source = "${baseurl}ddagent-cli-${agent_version}.msi"
  }

  if $ensure == 'present' {
    if ($agent_version in ['6.14.0', '6.14.1']) {
      fail('The specified agent version has been blacklisted, please specify a version other than 6.14.0 or 6.14.1')
    }

    file { 'installer':
      path     => $msi_full_path,
      source   => $msi_source,
      provider => 'windows',
    }

    exec { 'validate':
      command   => "\$blacklist = '928b00d2f952219732cda9ae0515351b15f9b9c1ea1d546738f9dc0fda70c336','78b2bb2b231bcc185eb73dd367bfb6cb8a5d45ba93a46a7890fd607dc9188194';\$fileStream = [system.io.file]::openread('${msi_full_path}'); \$hasher = [System.Security.Cryptography.HashAlgorithm]::create('sha256'); \$hash = \$hasher.ComputeHash(\$fileStream); \$fileStream.close(); \$fileStream.dispose();\$hexhash = [system.bitconverter]::tostring(\$hash).ToLower().replace('-','');if (\$blacklist.Contains(\$hexhash)) { Exit 1 }",
      provider  => 'powershell',
      logoutput => 'on_failure',
      require   => File['installer'],
      notify    => Package[$datadog_agent::params::package_name]
    }

    if $agent_version == 'latest' {
      $ensure_version = 'installed'
    } else {
      $ensure_version = $agent_version
    }

    package { $datadog_agent::params::package_name:
      ensure          => $ensure_version,
      provider        => 'windows',
      source          => $msi_full_path,
      install_options => ['/norestart', {'APIKEY' => $api_key, 'HOSTNAME' => $hostname, 'TAGS' => $tags}]
    }

    service { $service_name:
      ensure  => $service_ensure,
      enable  => $service_enable,
      require => Package[$datadog_agent::params::package_name]
    }
  } else {
    exec { 'datadog_6_14_fix':
      command  => "((New-Object System.Net.WebClient).DownloadFile('https://s3.amazonaws.com/ddagent-windows-stable/scripts/fix_6_14.ps1', \$env:temp + '\\fix_6_14.ps1')); &\$env:temp\\fix_6_14.ps1",
      provider => 'powershell',
    }

    package { $datadog_agent::params::package_name:
      ensure            => absent,
      provider          => 'windows',
      uninstall_options => ['/quiet'],
      subscribe         => Exec['datadog_6_14_fix'],
    }

  }
}
