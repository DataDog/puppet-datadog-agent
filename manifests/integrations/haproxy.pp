# Class: datadog_agent::integrations::haproxy
#
# lint:ignore:80chars
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
) inherits datadog_agent::params { # lint:ignore:class_inherits_from_params_class

  file {
    "${datadog_agent::params::conf_dir}/haproxy.yaml":
      ensure  => file,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0644',
      content => template('datadog_agent/agent-conf.d/haproxy.yaml.erb'),
      require => Class['datadog_agent'],
      notify  => Service[$datadog_agent::params::service_name]
  }
# lint:endignore
}
