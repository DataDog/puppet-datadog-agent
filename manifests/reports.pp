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
  $puppetmaster_user,
  $dogapi_version,
  $manage_dogapi_gem = true,
  $hostname_extraction_regex = undef,
  $proxy_http = undef,
  $proxy_https = undef,
  $report_fact_tags = [],
  $report_trusted_fact_tags = [],
  $datadog_site = 'datadoghq.com',
  $puppet_gem_provider = $datadog_agent::params::gem_provider,
) inherits datadog_agent::params {

  if ($::operatingsystem == 'Windows') {

    fail('Reporting is not yet supported from a Windows host')

  } else {

    require ::datadog_agent

    if $manage_dogapi_gem {
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

      package{ 'dogapi':
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
