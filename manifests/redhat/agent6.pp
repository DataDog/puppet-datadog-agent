# Class: datadog_agent::redhat::agent6
#
# This class contains the DataDog agent installation mechanism for Red Hat derivatives
#

class datadog_agent::redhat::agent6(
  String $baseurl = $datadog_agent::params::agent6_default_repo,
  String $gpgkey = 'https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public',
  Boolean $manage_repo = true,
  String $agent_version = 'latest',
  String $service_ensure = 'running',
  Boolean $service_enable = true,
) inherits datadog_agent::params {

  if $manage_repo {
    $public_key_local = '/etc/pki/rpm-gpg/DATADOG_RPM_KEY.public'

    yumrepo {'datadog':
      ensure   => absent,
    }

    yumrepo {'datadog5':
      ensure   => absent,
    }

    yumrepo {'datadog6':
      enabled  => 1,
      gpgcheck => 0,
      descr    => 'Datadog, Inc.',
      baseurl  => $baseurl
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
    hasstatus => false,
    pattern   => 'dd-agent',
    require   => Package[$datadog_agent::params::package_name],
    start     => 'initctl start datadog-agent',
    stop      => 'initctl stop datadog-agent',
    status    => 'initctl status datadog-agent',
    restart   => 'initctl restart datadog-agent',
  }
}
