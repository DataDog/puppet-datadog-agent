# Class: datadog_agent::integrations::rabbitmq
#
# This class will install the necessary config to hook the rabbitmq in the agent
#
# See the sample rabbitmq.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/rabbitmq/datadog_checks/rabbitmq/data/conf.yaml.example
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
#   $exchanges
#   $exchanges_regexes
#       Specify the exchanges to collect metrics on (up to 50 queues).
#       If you have less than 50 queues, metrics will be collected on all exchanges
#       by default.
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
  Optional[String] $url    = undef,
  String $username         = 'guest',
  String $password         = 'guest',
  Boolean $ssl_verify      = true,
  Boolean $tag_families    = false,
  Array $nodes             = [],
  Array $nodes_regexes     = [],
  Array $queues            = [],
  Array $queues_regexes    = [],
  Array $vhosts            = [],
  Array $exchanges         = [],
  Array $exchanges_regexes = [],
) inherits datadog_agent::params {
  require datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/rabbitmq.d"

  file { $dst_dir:
    ensure  => directory,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_directory,
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
  $dst = "${dst_dir}/conf.yaml"

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/rabbitmq.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
