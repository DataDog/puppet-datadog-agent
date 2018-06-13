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
#   $tag_families
#       Tag queues "families" based on regex match
#   $ssl_verify
#       Skip verification of the RabbitMQ management web endpoint 
#       SSL certificate 
#   $nodes
#   $nodes_regexes
#       Specify the nodes to collect metrics on (up to 100 nodes).
#       If you have less than 100 nodes, metrics will be collected on all nodes
#       by default.
#   $queues
#   $queues_regexes
#       Specify the queues to collect metrics on (up to 200 queues).
#
#       If you have less than 200 queues, metrics will be collected on all queues
#       by default.
#
#       If vhosts are set, set queue names as `vhost_name/queue_name`
#
#       If `tag families` are enabled, the first capture group in the regex will
#       be used as the queue_family tag
#   $vhosts
#       List of vhosts to monitor with service checks. By default, a list of all
#       vhosts is fetched and each one will be checked using the aliveness API.
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
  Optional[String] $url      = undef,
  Optional[String] $username = 'guest',
  Optional[String] $password = 'guest',
  Boolean $ssl_verify        = true,
  Boolean $tag_families      = false,
  Array $nodes               = [],
  Array $nodes_regexes       = [],
  Array $queues              = [],
  Array $queues_regexes      = [],
  Array $vhosts              = [],
) inherits datadog_agent::params {

  include datadog_agent

  if !$::datadog_agent::agent5_enable {
    $dst = "${datadog_agent::conf6_dir}/rabbitmq.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/rabbitmq.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/rabbitmq.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
