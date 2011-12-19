# Class: datadog::ubuntu
#
# This class contains the DataDog agent installation mechanism for Ubuntu
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class datadog::ubuntu {

    exec { "datadog_key":
      command => "/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C7A7DA52",
      unless  => "/usr/bin/apt-key list | grep C7A7DA52",
      notify  => Exec['datadog_apt-get_update'],
    }

    file { "/etc/apt/sources.list.d/datadog.list":
      source  => "puppet:///modules/datadog/datadog.list",
      notify  => Exec['datadog_apt-get_update'],
    }

    exec { 'datadog_apt-get_update':
      command     => '/usr/bin/apt-get update',
      refreshonly => true,
   }

    package { "datadog-agent":
      ensure => latest,
      require => [ File["/etc/apt/sources.list.d/datadog.list"], Exec['datadog_apt-get_update'] ],
    }

    service { "datadog-agent":
      ensure    => running,
      enable    => true,
      hasstatus => false,
      pattern   => 'dd-agent',
      require   => Package["datadog-agent"],
    }

}
