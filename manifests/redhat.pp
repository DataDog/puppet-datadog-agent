# Class: datadog::redhat
#
# This class contains the DataDog agent installation mechanism for Red Hat derivatives
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class datadog::redhat {

    file { "/etc/yum.repos.d/datadog.repo":
        content => template("$module_name/datadog.repo"),
        require => Package["python26"],
    }

    package { "datadog-agent":
      ensure => latest,
      require => File["/etc/yum.repos.d/datadog.repo"],
    }

    service { "datadog-agent":
      ensure => running,
      enable => true,
      hasstatus => false,
      status => "pgrep -f /usr/share/datadog/agent/agent.py",
      require => Package["datadog-agent"],
    }



}
