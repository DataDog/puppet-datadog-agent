# Class: datadog_agent::integrations::riak
#
# This class will install the necessary configuration for the riak integration
#
# Parameters:
#   $url:
#     The URL for riak
#   $tags
#       Optional array of tags
#
# Sample Usage:
#
#   include 'datadog_agent::integrations::riak'
#
#   OR
#
#   class { 'datadog_agent::integrations::riak' :
#     url   => 'http://localhost:8098/stats',
#   }
#
class datadog_agent::integrations::riak(
  String $url  = 'http://localhost:8098/stats',
  Array $tags  = [],
) inherits datadog_agent::params {
  require ::datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/riak.yaml"
  if $::datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/riak.d"
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

  file {
    $dst:
      ensure  => file,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_file,
      content => template('datadog_agent/agent-conf.d/riak.yaml.erb'),
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name]
  }
}
