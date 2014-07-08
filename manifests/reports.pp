# Class: datadog_agent::reports
#
# This class configures the puppetmaster for reporting back to 
# the datadog service.
#
# Parameters:
#   $api_key:
#       Your DataDog API Key. Please replace with your key value
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class datadog_agent::reports(
  $api_key,
  $puppetmaster_user
) {

  include datadog_agent::params
  $rubydev_package =$datadog_agent::params::rubydev_package

  # check to make sure that you're not installing rubydev somewhere else
  if defined(Package[$rubydev_package]) {
    # pass
    # puppet DSL lacks a 'not' in < 2.6.8
  } else {
    package {"$rubydev_package":
      ensure => installed,
      before => Package['dogapi'],
    }
  }

  file { "/etc/dd-agent/datadog.yaml":
    ensure   => file,
    content  => template("datadog_agent/datadog.yaml.erb"),
    owner    => $puppetmaster_user,
    group    => "root",
    mode     => 0640,
    require  => File["/etc/dd-agent"],
  }

  package{'dogapi':
    ensure    => 'installed',
    provider  => 'gem',
  }

}
