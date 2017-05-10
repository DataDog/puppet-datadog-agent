# Class: datadog_agent::integrations::twemproxy
#
# This class will install the necessary configuration for the twemproxy aka nutcracker integration
#
# Parameters:
#   $host:
#       The host twemproxy is running on. Defaults to '127.0.0.1'
#   $port
#       The twemproxy password for the datadog user. Defaults to 22222
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::twemproxy' :
#    servers => [
#      {
#        'host' => 'localhost',
#        'port' => '22222',
#      },
#      {
#        'host' => 'localhost',
#        'port' => '22223',
#      },
#    ]
#  }
#
class datadog_agent::integrations::twemproxy(
  $servers = [{'host' => 'localhost', 'port' => '22222'}]
) inherits datadog_agent::params {
  include datadog_agent

  validate_array($servers)

  file { "${datadog_agent::params::conf_dir}/twemproxy.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/twemproxy.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
