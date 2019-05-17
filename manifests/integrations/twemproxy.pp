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
#    instances => [
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
  $host = 'localhost',
  $port = '22222',
  $instances = undef,
) inherits datadog_agent::params {
  include datadog_agent

  if !$instances and $host {
    $_instances = [{
      'host' => $host,
      'port' => $port,
    }]
  } elsif !$instances{
    $_instances = []
  } else {
    $_instances = $instances
  }

  $legacy_dst = "${datadog_agent::conf_dir}/twemproxy.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/twemproxy.d"
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

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/twemproxy.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
