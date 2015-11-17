# Class: datadog_agent::integrations::rabbitmq
#
# This class will install the necessary config to hook the rabbitmq in the agent
#
# Parameters:
#   $url
#       Required. URL pointing to the RabbitMQ Managment Plugin
#       (http://www.rabbitmq.com/management.html)
#   $username
#   $password
#       If your service uses basic authentication, you can optionally
#       specify a username and password that will be used in the check.
#       (it's set to guest/guest by RabbitMQ on setup)
#
# Sample Usage:
#
# class { 'datadog_agent::integrations::rabbitmq':
#   url      => 'http://localhost:15672/api/',
#   username => 'guest',
#   password => 'guest',
# }
#

class datadog_agent::integrations::rabbitmq (
  $url       = undef,
  $username  = undef,
  $password  = undef,
  $queues    = undef,
  $vhosts    = undef,
) inherits datadog_agent::params {
  include datadog_agent

  file { "${datadog_agent::params::conf_dir}/rabbitmq.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/rabbitmq.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
