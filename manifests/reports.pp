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
  $datadog_site,
  $puppetmaster_user,
  $dogapi_version,
  $hostname_extraction_regex = nil
) {

  include datadog_agent
  include datadog_agent::params
  $rubydev_package = $datadog_agent::params::rubydev_package

  # check to make sure that you're not installing rubydev somewhere else
  if ! defined(Package[$rubydev_package]) {
    package {$rubydev_package:
      ensure => installed,
      before => Package['dogapi']
    }
  }

  if (! defined(Package['rubygems'])) {
    # Ensure rubygems is installed
    class { 'ruby':
      rubygems_update => false
    }
  }

  file { '/etc/datadog-agent/datadog-reports.yaml':
    ensure  => file,
    content => template('datadog_agent/datadog-reports.yaml.erb'),
    owner   => $puppetmaster_user,
    group   => 'root',
    mode    => '0640',
    require => File['/etc/datadog-agent'],
  }

  package{ 'dogapi':
    ensure   => $dogapi_version,
    provider => 'puppetserver_gem',
  }
}
