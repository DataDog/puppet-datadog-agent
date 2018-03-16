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
  $tags = [ 'name:ceph_cluster' ],
  $ceph_cmd = '/usr/bin/ceph',
) inherits datadog_agent::params {
  include datadog_agent

  validate_array($tags)

  file { '/etc/sudoers.d/datadog_ceph':
    content => "# This file is required for dd ceph \ndd-agent ALL=(ALL) NOPASSWD:/usr/bin/ceph\n"
  }

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/ceph.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/ceph.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/ceph.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
