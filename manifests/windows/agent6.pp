# Class: datadog_agent::windows::agent6
#
# This class contains the DataDog agent installation mechanism for Windows derivatives
#

class datadog_agent::windows::agent6(
  String $service_ensure = 'running',
  String $baseurl = $datadog_agent::params::agent6_default_repo,
  String $msi = $datadog_agent::params::datadog_win_msi,
  String $msi_destination = $datadog_agent::params::win_msi_location,
  String $api_key = $datadog_agent::api_key,
  String $hostname = $datadog_agent::host,
  String $service_name = $datadog_agent::service_name_win,
  Array  $tags = $datadog_agent::tags,
  Boolean $service_enable = true,
  Boolean $should_install = $datadog_agent::should_install_win
) inherits datadog_agent::params {

	if $should_install {
	  file { $msi_destination:
      ensure        => directory,
      owner         => 'Administrator',
      group         => 'Administrators',
      notify        => Exec['downloadmsi']
  	}

    exec { 'downloadmsi':
      command       => "Invoke-WebRequest $baseurl -outfile $msi",
      onlyif        => "if ((test-path $msi) -eq \$true) {exit 1}",
      provider      => powershell,
      notify        => Package['Datadog Agent']
    }

    package { 'Datadog Agent':
      ensure            => installed,
      provider          => 'windows',
      source            => "$msi",
      install_options   => ['/quiet', {'APIKEY' => $api_key, 'HOSTNAME' => $hostname, 'TAGS' => $tags}]
    }

    exec { 'DatadogRestart':
      command           => "& 'C:/Program Files/Datadog/Datadog Agent/embedded/agent.exe' restart-service",
      provider          => powershell
    }

    service { $service_name:
      ensure        => $service_ensure,
      enable        => $service_enable,
      require       => Package['Datadog Agent']
    }
	} else {
    file { $msi_destination:
      ensure        => absent,
      owner         => 'Administrator',
      group         => 'Administrators',
      notify        => Package['Datadog Agent']
    }

    package { 'Datadog Agent':
      ensure                 => absent,
      uninstall_options      => ['/quiet']
    }
  }
}