# Class: datadog_agent::integrations::zk
#
# This class will install the necessary configuration for the zk integration
#
# Parameters:
#   @param servers
#
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::zk' :
#    servers => [
#      {
#        'host' => 'localhost',
#        'port' => '2181',
#        'tags' => [],
#      },
#      {
#        'host' => 'localhost',
#        'port' => '2182',
#        'tags' => [],
#      },
#    ]
#  }
#
class datadog_agent::integrations::zk (
  Array $servers = [{ 'host' => 'localhost', 'port' => '2181' }]
) inherits datadog_agent::params {
  require datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/zk.yaml"
  if versioncmp($datadog_agent::_agent_major_version, '5') > 0 {
    $dst_dir = "${datadog_agent::params::conf_dir}/zk.d"
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
    content => template('datadog_agent/agent-conf.d/zk.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
