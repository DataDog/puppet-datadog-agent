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

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/haproxy.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/haproxy.yaml"
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
