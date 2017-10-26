# Class: datadog_agent::integrations::zk
#
# This class will install the necessary configuration for the zk integration
#
# Parameters:
#   $host:
#       The host zk is running on. Defaults to '127.0.0.1'
#   $port
#       The port zk is running on. Defaults to 2181
#   $tags
#       Optional array of tags
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
  $servers = [{'host' => 'localhost', 'port' => '2181'}]
) inherits datadog_agent::params {
  include datadog_agent

  validate_array($servers)

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/zk.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/zk.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/zk.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
