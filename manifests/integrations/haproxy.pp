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
#     url   => 'http://localhost:8080',
#     creds => { username => 'admin',
#                password => 'password',
#              },
#   }
#
class datadog_agent::integrations::haproxy(
  $creds = {},
  $url   = "http://${::ipaddress}:8080",
) inherits datadog_agent::params {
  include datadog_agent

  file {
    "${datadog_agent::params::conf_dir}/haproxy.yaml":
      ensure  => file,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0644',
      content => template('datadog_agent/agent-conf.d/haproxy.yaml.erb'),
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name]
  }
}
