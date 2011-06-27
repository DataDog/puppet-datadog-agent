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
class datadog::ubuntu

    exec { "get datadog key":
      command => "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C7A7DA52",
      unless => "apt-key list | grep C7A7DA52",
    }

    file { "/etc/apt/sources.list.d/datadog.list":
      source => "puppet:///datadog/datadog.list",
    }

    exec { "apt-get update":
      require => Exec["get datadog key"],
   }
}
