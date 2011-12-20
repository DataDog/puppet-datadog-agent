# Class: datadog
#
# This class contains the agent installation mechanism for the Datadog module
#
# Parameters:
#   $api_key:
#       Your DataDog API Key. Please replace with your key value
#   $puppet_run_reports
#       Will send results from your puppet agent runs back to the datadog service
#   $puppetmaster_user
#       Will chown the api key used by the report processor to this user.
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
  $puppet_run_reports = false,
  $puppetmaster_user = 'puppet'
) inherits datadog::params {

  include datadog::params
  $dd_url  = $datadog::params::dd_url

  case $operatingsystem {
    "Ubuntu","Debian": { include datadog::ubuntu }
    "RedHat","CentOS","Fedora": { include datadog::redhat }
    default: { notify{'Unsupported OS': message => 'The DataDog module only support Red Hat and Ubuntu derivatives'} }
  }

  file { "/etc/dd-agent":
    ensure   => present,
    owner    => "root",
    group    => "root",
    mode     => 0755,
    require  => Package["datadog-agent"],
  }

  # main agent config file
  file { "/etc/dd-agent/datadog.conf":
    ensure   => file,
    content  => template("datadog/datadog.conf.erb"),
    owner    => "dd-agent",
    group    => "root",
    mode     => 0640,
    notify   => Service["datadog-agent"],
    require  => File["/etc/dd-agent"],
  }

  if $puppet_run_reports {
    class { 'datadog::reports':
      api_key           => $api_key,
      puppetmaster_user => $puppetmaster_user,
    }
  }

}
