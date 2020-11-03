# Class: datadog_agent::redhat
#
# This class contains the DataDog agent installation mechanism for Red Hat derivatives
#

class datadog_agent::redhat(
  Integer $agent_major_version = $datadog_agent::params::default_agent_major_version,
  Optional[String] $agent_repo_uri = undef,
  Boolean $manage_repo = true,
  String $agent_version = $datadog_agent::params::agent_version,
) inherits datadog_agent::params {

  if $manage_repo {

    $keys = [
        'https://yum.datadoghq.com/DATADOG_RPM_KEY.public',
        'https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public',
        'https://yum.datadoghq.com/DATADOG_RPM_KEY_20200908.public',
    ]

    case $agent_major_version {
      5 : {
        $defaulturl = "https://yum.datadoghq.com/rpm/${::architecture}/"
        $gpgkeys = $keys
      }
      6 : {
        $defaulturl = "https://yum.datadoghq.com/stable/6/${::architecture}/"
        $gpgkeys = $keys
      }
      7 : {
        $defaulturl = "https://yum.datadoghq.com/stable/7/${::architecture}/"
        $gpgkeys = $keys[1,2]
      }
      default: { fail('invalid agent_major_version') }
    }

    if ($agent_repo_uri != undef) {
      $baseurl = $agent_repo_uri
    } else {
      $baseurl = $defaulturl
    }

    yumrepo { 'datadog-beta':
      ensure => absent,
    }

    yumrepo {'datadog5':
      ensure   => absent,
    }

    yumrepo {'datadog6':
      ensure   => absent,
    }

    yumrepo {'datadog':
      enabled  => 1,
      gpgcheck => 1,
      gpgkey   => join($gpgkeys, "\n       "),
      descr    => 'Datadog, Inc.',
      baseurl  => $baseurl,
    }

    package { $datadog_agent::params::package_name:
      ensure  => $agent_version,
      require => Yumrepo['datadog'],
    }
  } else {
    package { $datadog_agent::params::package_name:
      ensure  => $agent_version,
    }
  }
}
