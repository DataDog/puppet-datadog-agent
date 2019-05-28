# Class: datadog_agent::integrations::haproxy
#
# This class will install the necessary configuration for the haproxy integration
#
# Parameters:
#   $url:
#     The URL for haproxy
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::haproxy' :
#     url     => 'http://localhost:8080',
#     creds   => { username => 'admin',
#                  password => 'password',
#                },
#     options => { collect_aggregates_only => 'False' },
#   }
#
class datadog_agent::integrations::haproxy(
  $creds     = {},
  $url       = "http://${::ipaddress}:8080",
  $options   = {},
  $instances = undef,
) inherits datadog_agent::params {
  include datadog_agent

  if !$instances and $url {
    $_instances = [{
      'creds'   => $creds,
      'url'     => $url,
      'options' => $options,
    }]
  } elsif !$instances {
    $_instances = []
  } else {
    $_instances = $instances
  }

  $legacy_dst = "${datadog_agent::conf_dir}/haproxy.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/haproxy.d"
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
      mode    => '0644',
      content => template('datadog_agent/agent-conf.d/haproxy.yaml.erb'),
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name]
  }
}
