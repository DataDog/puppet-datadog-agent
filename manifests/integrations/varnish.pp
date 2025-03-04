# Class: datadog_agent::integrations::varnish
#
# This class will install the necessary configuration for the varnish integration
#
# See the sample varnish.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/varnish/datadog_checks/varnish/data/conf.yaml.example
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
  String $varnishstat             = '/usr/bin/varnishstat',
  Optional[String] $instance_name = undef,
  Array $tags                     = [],
) inherits datadog_agent::params {
  require datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/varnish.d"

  file { $dst_dir:
    ensure  => directory,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_directory,
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
  $dst = "${dst_dir}/conf.yaml"

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/varnish.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
