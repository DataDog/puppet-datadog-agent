# Class: datadog
#
# This class contains the agent installation mechanism for the Datadog module
#
# Parameters:
#   $api_key:
#       Your DataDog API Key. Please replace with your key value
#   $dd_url
#       The URL to the DataDog application.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# include datadog
#
# or
#
# class{'datadog': api_key => 'your key'}
#
#
class datadog(
  $api_key = 'your key',
) inherits datadog::params {

  $dd_url  = $datadog::params::dd_url

  case $operatingsystem {
    "Ubuntu","Debian": { include datadog::ubuntu }
    "RedHat","CentOS","Fedora": { include datadog::redhat }
    default: { fail("The DataDog module only support Red Hat and Ubuntu derivatives") }
  }

  file { "/etc/dd-agent":
    ensure   => present,
    owner    => "root",
    group    => "root",
    mode     => 0755,
    require  => Package["datadog-agent"],
  }

  file { "/etc/dd-agent/datadog.conf":
    ensure   => present,
    content  => template("datadog/datadog.conf.erb"),
    owner    => "dd-agent",
    group    => "root",
    mode     => 0640,
    notify   => Service["datadog-agent"],
    require  => File["/etc/dd-agent"],
  }

}
