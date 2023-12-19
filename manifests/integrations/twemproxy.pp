# Class: datadog_agent::integrations::twemproxy
#
# This class will install the necessary configuration for the twemproxy aka nutcracker integration
#
# Parameters:
#   @param host
#       The host twemproxy is running on. Defaults to '127.0.0.1'
#   @param port
#       The twemproxy password for the datadog user. Defaults to 22222
#   @param instances
#
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
class datadog_agent::integrations::twemproxy (
  String $host                   = 'localhost',
  Variant[String, Integer] $port = '22222',
  Optional[Array] $instances     = undef,
) inherits datadog_agent::params {
  require datadog_agent

  if !$instances and $host {
    $_instances = [{
        'host' => $host,
        'port' => $port,
    }]
  } elsif !$instances {
    $_instances = []
  } else {
    $_instances = $instances
  }

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/twemproxy.yaml"
  if versioncmp($datadog_agent::_agent_major_version, '5') > 0 {
    $dst_dir = "${datadog_agent::params::conf_dir}/twemproxy.d"
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
    content => template('datadog_agent/agent-conf.d/twemproxy.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
