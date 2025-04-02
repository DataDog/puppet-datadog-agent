# Class: datadog_agent::reports
#
# This class configures the puppetmaster for reporting back to
# the datadog service.
#
# Parameters:
# @param api_key Sensitive[String]:Your DataDog API Key.
#   $datadog_site:
#       URL to use to talk to the Datadog API
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class datadog_agent::reports (
  Sensitive[String] $api_key = 'your_API_key',
  String $puppetmaster_user,
  String $dogapi_version,
  Boolean $manage_dogapi_gem = true,
  Optional[String] $hostname_extraction_regex = undef,
  Optional[String] $proxy_http = undef,
  Optional[String] $proxy_https = undef,
  Array $report_fact_tags = [],
  Array $report_trusted_fact_tags = [],
  String $datadog_site = 'https://api.datadoghq.com',
  String $puppet_gem_provider = $datadog_agent::params::gem_provider,
) inherits datadog_agent::params {
  if ($facts['os']['name'] == 'Windows') {
    fail('Reporting is not yet supported from a Windows host')
  } else {
    require datadog_agent

    if $manage_dogapi_gem {
      $rubydev_package = $datadog_agent::params::rubydev_package

      # check to make sure that you're not installing rubydev somewhere else
      if ! defined(Package[$rubydev_package]) {
        package { $rubydev_package:
          ensure => installed,
          before => Package['dogapi'],
        }
      }

      if (! defined(Package['rubygems'])) {
        package { 'ruby':
          ensure => 'installed',
          name   => $datadog_agent::params::ruby_package,
        }

        package { 'rubygems':
          ensure  => 'installed',
          name    => $datadog_agent::params::rubygems_package,
          require => Package['ruby'],
        }
      }

      package { 'dogapi':
        ensure   => $dogapi_version,
        provider => $puppet_gem_provider,
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
  }
}
