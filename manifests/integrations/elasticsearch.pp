# Class: datadog_agent::integrations::elasticsearch
#
# This class will install the necessary configuration for the elasticsearch integration
#
# See the sample elastic.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/elastic/datadog_checks/elastic/data/conf.yaml.example
#
# Parameters:
#   $url:
#     The URL for Elasticsearch
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::elasticsearch' :
#     instances => [{
#       url  => "http://localhost:9201"
#     },
#     {
#       url  => "http://elastic.acme.com:9201"
#     }]
#   }
#
# Or for a single instance:
#
#  class { 'datadog_agent::integrations::elasticsearch' :
#    url  => "http://localhost:9201"
#  }
#
class datadog_agent::integrations::elasticsearch (
  Boolean $cluster_stats     = false,
  Boolean $index_stats       = false,
  Optional[String] $password = undef,
  Boolean$pending_task_stats = true,
  Boolean $pshard_stats      = false,
  Optional[String] $ssl_cert = undef,
  Optional[String] $ssl_key  = undef,
  Boolean $ssl_verify        = true, #kept for backwards compatibility
  Boolean $tls_verify        = $ssl_verify,
  Array $tags                = [],
  String $url                = 'http://localhost:9200',
  Optional[String] $username = undef,
  Optional[Array] $instances = undef
) inherits datadog_agent::params {
  require datadog_agent

  if !$instances and $url {
    $_instances = [{
        'cluster_stats'      => $cluster_stats,
        'index_stats'        => $index_stats,
        'password'           => $password,
        'pending_task_stats' => $pending_task_stats,
        'pshard_stats'       => $pshard_stats,
        'ssl_cert'           => $ssl_cert,
        'ssl_key'            => $ssl_key,
        'tls_verify'         => $tls_verify,
        'tags'               => $tags,
        'url'                => $url,
        'username'           => $username
    }]
  } elsif !$instances {
    $_instances = []
  } else {
    $_instances = $instances
  }

  $dst_dir = "${datadog_agent::params::conf_dir}/elastic.d"

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
    mode    => $datadog_agent::params::permissions_file,
    content => template('datadog_agent/agent-conf.d/elastic.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
