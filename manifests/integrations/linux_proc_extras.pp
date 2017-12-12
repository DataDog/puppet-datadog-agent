# Class: datadog_agent::integrations::system_core
#
# This class will install the necessary configuration for the CPU cores integration
#
# Parameters:
#
#   tags
#       The (optional) tags to add to the check instance.
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::linux_proc_extras':
#      tags => [ 'env:production' ],
#  }

class datadog_agent::integrations::linux_proc_extras(
  $tags = [],
) inherits datadog_agent::params {
  include datadog_agent

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/linux_proc_extras.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/linux_proc_extras.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/linux_proc_extras.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }

}
