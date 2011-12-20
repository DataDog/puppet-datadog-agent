# Class: datadog::reports
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
class datadog::reports(
  $api_key,
  $puppetmaster_user
) {

  include datadog::params
  $rubygems_package = $datadog::params::rubygems_package
  $rubydev_package =$datadog::params::rubydev_package

  # check to make sure that you're not installing rubygems somewhere else,
  # and install it if it's not defined elsewhere in your puppet catalog 
  if defined(Package[$rubygems_package]) {
    # pass
    # puppet DSL lacks a 'not' in < 2.6.8
  } else {
    package {"$rubygems_package":
      ensure => installed,
      before => Package['dogapi'],
    }
  }

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
    content  => template("datadog/datadog.yaml.erb"),
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
