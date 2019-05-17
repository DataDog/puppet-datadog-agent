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
  include datadog_agent

  validate_legacy('String', 'validate_string', $url)
  validate_legacy('Array', 'validate_array', $tags)

  $legacy_dst = "${datadog_agent::conf_dir}/riak.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/riak.d"
    file { $legacy_dst:
      ensure => 'absent'
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0755',
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
      mode    => '0644',
      content => template('datadog_agent/agent-conf.d/riak.yaml.erb'),
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name]
  }
}
