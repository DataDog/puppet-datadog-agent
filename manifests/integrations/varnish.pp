# Class: datadog_agent::integrations::varnish
#
# This class will install the necessary configuration for the varnish integration
#
# Parameters:
#   varnishstat
#       Path to the varnishstat binary
#
#   instance_name
#       Used in the varnishstat command for the -n argument
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
  $varnishstat   = '/usr/bin/varnishstat',
  $instance_name = undef,
  $tags          = [],
) inherits datadog_agent::params {
  include datadog_agent

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/varnish.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/varnish.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/varnish.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
