# Class: datadog_agent::redhat
#
# This class contains the DataDog agent installation mechanism for Red Hat derivatives
#
# Parameters:
#   $baseurl:
#       Baseurl for the datadog yum repo
#       Defaults to http://yum.datadoghq.com/rpm/${::architecture}/
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#
class datadog_agent::redhat::agent5(
  String $baseurl = $datadog_agent::params::agent5_default_repo,
  String $gpgkey = 'https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public',
  Boolean $manage_repo = true,
  String $agent_version = 'latest',
  String $service_ensure = 'running',
  Boolean $service_enable = true,
) inherits datadog_agent::params {

  if $manage_repo {
    $public_key_local = '/etc/pki/rpm-gpg/DATADOG_RPM_KEY.public'


    if ($facts['yum_agent6_repo'] or $facts['yum_datadog_legacy_repo']) and $agent_version == 'latest' {
      exec { 'datadog_yum_remove_agent6':
        command     => '/usr/bin/yum -y -q remove datadog-agent',
      }
    } else {
      exec { 'datadog_yum_remove_agent6':
        command     => ':',  # NOOP builtin
        noop        => true,
        refreshonly => true,
        provider    => 'shell',
      }
    }

    yumrepo {'datadog':
      ensure => absent,
      notify => Exec['datadog_yum_remove_agent6'],
    }

    yumrepo {'datadog6':
      ensure => absent,
      notify => Exec['datadog_yum_remove_agent6'],
    }

    yumrepo {'datadog5':
      enabled  => 1,
      gpgcheck => 0,
      descr    => 'Datadog, Inc.',
      baseurl  => $baseurl,
    }

    Package { require => Yumrepo['datadog5']}
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
