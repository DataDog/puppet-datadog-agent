# Class: datadog_agent::integrations::ceph
#
# This class will install the necessary configuration for the ceph integration
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
class datadog_agent::integrations::ceph(
  Array $tags = [ 'name:ceph_cluster' ],
  String $ceph_cmd = '/usr/bin/ceph',
) inherits datadog_agent::params {
  require ::datadog_agent

  file { '/etc/sudoers.d/datadog_ceph':
    content => "# This file is required for dd ceph \ndd-agent ALL=(ALL) NOPASSWD:/usr/bin/ceph\n"
  }

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/ceph.yaml"
  if $::datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/ceph.d"
    file { $legacy_dst:
      ensure => 'absent'
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name]
    }
    $dst = "${dst_dir}/conf.yaml"
  } else {
    $dst = $legacy_dst
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/ceph.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
