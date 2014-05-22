# Class: datadog
#
# This class contains the agent installation mechanism for the Datadog module
#
# Parameters:
#   $host:
#       Your hostname to see in Datadog. Defaults with $fqdn
#   $api_key:
#       Your DataDog API Key. Please replace with your key value
#   $use_pup:
#       Use Pup. Boolean. Defaults to false
#   $tags
#       Optional array of tags
#   $puppet_run_reports
#       Will send results from your puppet agent runs back to the datadog
#       service
#   $puppetmaster_user
#       Will chown the api key used by the report processor to this user.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# class { 'datadog':
#     api_key   => 'your key',
#     tags      => ['env:production', 'linux'],
#     use_pup   => false,
#     puppet_run_reports  => false,
#     puppetmaster_user   => puppet,
#}
#
class datadog (
  $host               = $fqdn,
  $api_key            = 'your_API_key',
  $use_pup            = false,
  $tags               = [],
  $puppet_run_reports = false,
  $puppetmaster_user  = 'puppet',
  $puppetmaster_report_host_filter = '.*') inherits datadog::params {
  validate_string($api_key)
  validate_bool($use_pup)
  validate_array($tags)

  include datadog::params
  $dd_url = $datadog::params::dd_url

  case $operatingsystem {
    "Ubuntu", "Debian" : {
      include datadog::ubuntu
    }
    "RedHat", "CentOS", "Fedora", "Amazon", "Scientific" : {
      include datadog::redhat
    }
    default            : {
      fail("Class[datadog]: Unsupported operatingsystem: ${::operatingsystem}")
    }
  }

  file { "/etc/dd-agent":
    ensure  => present,
    owner   => "root",
    group   => "root",
    mode    => 0755,
    require => Package["datadog-agent"],
  }

  # main agent config file
  file { "/etc/dd-agent/datadog.conf":
    ensure  => file,
    content => template("datadog/datadog.conf.erb"),
    owner   => $dd_user,
    group   => $dd_group,
    mode    => 0640,
    notify  => Service[$service_name],
    require => File["/etc/dd-agent"],
  }

  if $puppet_run_reports {
    class { 'datadog::reports':
      api_key           => $api_key,
      puppetmaster_user => $puppetmaster_user,
      puppetmaster_report_host_filter => $puppetmaster_report_host_filter,
    }
  }

}
