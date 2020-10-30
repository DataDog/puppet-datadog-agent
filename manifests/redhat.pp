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

    case $agent_major_version {
      5 : {
        $defaulturl = "https://yum.datadoghq.com/rpm/${::architecture}/"
        $gpgkeys = ['https://yum.datadoghq.com/DATADOG_RPM_KEY.public']
      }
      6 : {
        $defaulturl = "https://yum.datadoghq.com/stable/6/${::architecture}/"
        $gpgkeys = ['https://yum.datadoghq.com/DATADOG_RPM_KEY.public']
      }
      7 : {
        $defaulturl = "https://yum.datadoghq.com/stable/7/${::architecture}/"
        $gpgkeys = ['https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public', 'https://yum.datadoghq.com/DATADOG_RPM_KEY_20200908.public']
      }
      default: { fail('invalid agent_major_version') }
    }

    if ($agent_repo_uri != undef) {
      $baseurl = $agent_repo_uri
    } else {
      $baseurl = $defaulturl
    }

    $public_key_local = '/etc/pki/rpm-gpg/DATADOG_RPM_KEY.public'

    file { 'DATADOG_RPM_KEY_20200908.public':
        owner  => root,
        group  => root,
        mode   => '0600',
        path   => $public_key_local,
        source => 'https://yum.datadoghq.com/DATADOG_RPM_KEY_20200908.public'
    }

    exec { 'install-gpg-key':
        command => "/bin/rpm --import ${public_key_local}",
        onlyif  => "/usr/bin/gpg --dry-run --quiet --with-fingerprint -n ${public_key_local} | grep 'C655 9B69 0CA8 82F0 23BD  F3F6 3F4D 1729 FD4B F915' || gpg --dry-run --import --import-options import-show ${public_key_local} | grep 'C6559B690CA882F023BDF3F63F4D1729FD4BF915'",
        unless  => '/bin/rpm -q gpg-pubkey-fd4bf915',
        require => File['DATADOG_RPM_KEY_20200908.public'],
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
      require  => Exec['install-gpg-key'],
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
