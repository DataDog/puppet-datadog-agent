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

    exec { "get datadog key":
      command => "/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C7A7DA52",
      unless => "/usr/bin/apt-key list | grep C7A7DA52",
    }

    file { "/etc/apt/sources.list.d/datadog.list":
      source => "puppet:///modules/datadog/datadog.list",
    }

    exec { "/usr/bin/apt-get update":
      require => Exec["get datadog key"],
   }

    package { "datadog-agent":
      ensure => latest,
      require => File["/etc/apt/sources.list.d/datadog.list"],
    }

    service { "datadog-agent":
      ensure => running,
      enable => true,
      require => Package["datadog-agent"],
    }

}
