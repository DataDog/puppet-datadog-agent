# Class: datadog
#
# This class contains the agent installation mechanism for the Datadog module
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class datadog {

    include datadog::params

    $api_key = $datadog::params::api_key
    $dd_url  = $datadog::params::dd_url

    case $operatingsystem {
      "Ubuntu","Debian": { include datadog::ubuntu }
      "RedHat","CentOS","Fedora": { include datadog::redhat }
      default: { fail("The DataDog module only support Red Hat and Ubuntu derivatives") }
    }

   file { "/etc/dd-agent":
     ensure => present,
     owner => "root",
     group => "root",
     mode => 0755,
     require => Package["datadog-agent"],
   }

   file { "/etc/dd-agent/datadog.conf":
     ensure => present,
     content => template("datadog/datadog.conf.erb"),
     owner => "root",
     group => "root",
     mode => 0644,
     notify => Service["datadog-agent"],
     require => File["/etc/dd-agent"],
   }
}
