# @summary Install the necessary configuration for the varnish integration
#
#
# @param varnishstat
#   Path to the varnishstat binary
# @param instance_name
#   Used in the varnishstat command for the -n argument
# @param tags
#   DataDog tags
#
#
# @example
#   include 'datadog_agent::integrations::varnish'
#
# @example
#   class { 'datadog_agent::integrations::varnish':
#     url      => '/usr/bin/varnishstat',
#     tags     => ['env:production'],
#   }
#
class datadog_agent::integrations::varnish (
  Stdlib::Absolutepath $varnishstat   = '/usr/bin/varnishstat',
  Optional[Strin]      $instance_name = undef,
  Array                $tags          = [],
) inherits datadog_agent::params {
  require datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/varnish.yaml"
  if $datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/varnish.d"
    file { $legacy_dst:
      ensure => 'absent',
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name],
    }
    $dst = "${dst_dir}/conf.yaml"
  } else {
    $dst = $legacy_dst
  }

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
