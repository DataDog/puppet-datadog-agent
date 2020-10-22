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
        $gpgkey = 'https://yum.datadoghq.com/DATADOG_RPM_KEY.public'
      }
      6 : {
        $defaulturl = "https://yum.datadoghq.com/stable/6/${::architecture}/"
        $gpgkey = 'https://yum.datadoghq.com/DATADOG_RPM_KEY.public'
      }
      7 : {
        $defaulturl = "https://yum.datadoghq.com/stable/7/${::architecture}/"
        $gpgkey = 'https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public'
      }
      default: { fail('invalid agent_major_version') }
    }

    if ($agent_repo_uri != undef) {
      $baseurl = $agent_repo_uri
    } else {
      $baseurl = $defaulturl
    }

    $public_key_local = '/etc/pki/rpm-gpg/DATADOG_RPM_KEY.public'

    file { 'DATADOG_RPM_KEY_E09422B3.public':
        owner  => root,
        group  => root,
        mode   => '0600',
        path   => $public_key_local,
        source => 'https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public'
    }

    exec { 'install-gpg-key':
        command => "/bin/rpm --import ${public_key_local}",
        onlyif  => "/usr/bin/gpg --dry-run --quiet --with-fingerprint -n ${public_key_local} | grep 'A4C0 B90D 7443 CF6E 4E8A  A341 F106 8E14 E094 22B3' || gpg --dry-run --import --import-options import-show ${public_key_local} | grep 'A4C0B90D7443CF6E4E8AA341F1068E14E09422B3'",
        unless  => '/bin/rpm -q gpg-pubkey-e09422b3',
        require => File['DATADOG_RPM_KEY_E09422B3.public'],
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
      gpgkey   => $gpgkey,
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
