# Class: datadog_agent::integrations::supervisord
#
# This class will install the necessary configuration for the supervisord integration
#
# Parameters:
#   servername
#   socket
#       Optional. The socket on which supervisor listen for HTTP/XML-RPC requests. 
#   hostname
#       Optional. The host where supervisord server is running. 
#   port
#       Optional. The port number.
#   username
#   password
#       If your service uses basic authentication, you can optionally
#       specify a username and password that will be used in the check.
#   proc_names
#       Optional. The process to monitor within this supervisord instance.
#       If not specified, the check will monitor all processes. 
#   server_check
#       Optional. Service check for connections to supervisord server.
#
#
# Sample Usage:
#
# class { 'datadog_agent::integrations::supervisord':
#   instances => [
#     {
#       servername => 'server0',
#       socket     => 'unix:///var/run//supervisor.sock',
#     },
#     {
#       servername => 'server1',
#       hostname   => 'localhost',
#       port       => '9001',
#       proc_names => ['java', 'apache2'],
#     },
#   ],
# }
#
#
#

class datadog_agent::integrations::supervisord (
  $instances    = [{'servername' => 'server0', 'hostname' => 'localhost', 'port' => '9001'}],
) inherits datadog_agent::params {
  include datadog_agent

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/supervisord.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/supervisord.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/supervisord.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
