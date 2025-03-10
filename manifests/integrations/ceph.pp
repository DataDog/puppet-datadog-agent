# Class: datadog_agent::integrations::ceph
#
# This class will install the necessary configuration for the ceph integration
#
# See the sample ceph.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/ceph/datadog_checks/ceph/data/conf.yaml.example
#
# Parameters:
#   $tags
#       Optional array of tags
#   $ceph_cmd
#       Optional ceph cmd

# Sample Usage:
#
#  class { 'datadog_agent::integrations::ceph' :
#  }
#
class datadog_agent::integrations::ceph (
  Array $tags = ['name:ceph_cluster'],
  String $ceph_cmd = '/usr/bin/ceph',
) inherits datadog_agent::params {
  require datadog_agent

  file { '/etc/sudoers.d/datadog_ceph':
    content => "# This file is required for dd ceph \ndd-agent ALL=(ALL) NOPASSWD:/usr/bin/ceph\n",
  }

  $dst_dir = "${datadog_agent::params::conf_dir}/ceph.d"

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
    content => template('datadog_agent/agent-conf.d/ceph.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
