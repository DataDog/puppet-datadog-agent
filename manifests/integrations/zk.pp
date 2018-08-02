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
) {

  file { '/etc/datadog-agent/conf.d/zk.d':
    ensure  => directory,
    purge   => false,
    recurse => true,
    force   => false,
    owner   => 'dd-agent',
    group   => 'root'
  }

  file { '/etc/datadog-agent/conf.d/zk.d/zk.yaml':
    ensure  => file,
    owner   => 'dd-agent',
    group   => 'root',
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/zk.yaml.erb'),
    require => Package['datadog-agent'],
    notify  => Service['datadog-agent']
  }
}
