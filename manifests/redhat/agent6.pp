# Class: datadog_agent::redhat::agent6
#
# This class contains the DataDog agent installation mechanism for Red Hat derivatives
#

class datadog_agent::redhat::agent6(
  $baseurl = $datadog_agent::params::agent6_default_repo,
  $gpgkey = 'https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public',
  $manage_repo = true,
  $agent_version = 'latest',
  $service_ensure = 'running',
  $service_enable = true,
) inherits datadog_agent::params {

  validate_bool($manage_repo)
  if $manage_repo {
    $public_key_local = '/etc/pki/rpm-gpg/DATADOG_RPM_KEY.public'

    validate_string($baseurl)

    file { 'DATADOG_RPM_KEY.public':
        owner  => root,
        group  => root,
        mode   => '0600',
        path   => $public_key_local,
        source => $gpgkey
    }

    exec { 'install-gpg-key':
        command => "/bin/rpm --import ${public_key_local}",
        onlyif  => "/usr/bin/gpg --quiet --with-fingerprint -n ${public_key_local} | grep \'A4C0 B90D 7443 CF6E 4E8A  A341 F106 8E14 E094 22B3\'",
        unless  => '/bin/rpm -q gpg-pubkey-e09422b3',
        require => File['DATADOG_RPM_KEY.public'],
    }

    yumrepo {'datadog':
      ensure   => absent,
    }

    yumrepo {'datadog5':
      ensure   => absent,
    }

    yumrepo {'datadog6':
      enabled  => 1,
      gpgcheck => 1,
      gpgkey   => 'https://yum.datadoghq.com/DATADOG_RPM_KEY.public',
      descr    => 'Datadog, Inc.',
      baseurl  => $baseurl,
      require  => Exec['install-gpg-key'],
    }

    Package { require => Yumrepo['datadog6']}
  }

  package { 'datadog-agent-base':
    ensure => absent,
    before => Package[$datadog_agent::params::package_name],
  }

  package { $datadog_agent::params::package_name:
    ensure  => $agent_version,
  }

  service { $datadog_agent::params::service_name:
    ensure    => $service_ensure,
    enable    => $service_enable,
    hasstatus => false,
    pattern   => 'dd-agent',
    require   => Package[$datadog_agent::params::package_name],
  }

}
