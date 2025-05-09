# Class: datadog_agent::integrations::system_core
#
# This class will install the necessary configuration for the CPU cores integration
#
# See the sample linux_proc_extras.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/linux_proc_extras/datadog_checks/linux_proc_extras/data/conf.yaml.example
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
class datadog_agent::integrations::linux_proc_extras (
  Array $tags = [],
) inherits datadog_agent::params {
  require datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/linux_proc_extras.d"

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
    content => template('datadog_agent/agent-conf.d/linux_proc_extras.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
