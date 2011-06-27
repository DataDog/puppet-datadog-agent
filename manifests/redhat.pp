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
class datadog::redhat

    file { "/etc/yum.repo.d/datadog.repo":
      source => "puppet:///datadog/datadog.repo",
    }

    exec { "yum update":
      require => File["/etc/yum.repo.d/datadog.repo"],
   }
}
