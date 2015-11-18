# Class: datadog_agent::integrations::varnish
#
# This class will install the necessary configuration for the varnish integration
#
# Parameters:
#   varnishstat
#       Path to the varnishstat binary
#
#   tags
#       DataDog tags
#
# Sample usage:
#
# include 'datadog_agent::integrations::varnish'
#
# class { 'datadog_agent::integrations::varnish':
#   url      => '/usr/bin/varnishstat',
#   tags     => ['env:production'],
# }
#
class datadog_agent::integrations::varnish (
  $varnishstat = '/usr/bin/varnishstat',
  $tags      = [],
) inherits datadog_agent::params {
  include datadog_agent

  file { "${datadog_agent::params::conf_dir}/varnish.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/varnish.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
