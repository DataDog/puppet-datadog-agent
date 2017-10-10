# Class: datadog_agent::integrations::elasticsearch
#
# This class will install the necessary configuration for the elasticsearch integration
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
class datadog_agent::integrations::elasticsearch(
  $cluster_stats      = false,
  $password           = undef,
  $pending_task_stats = true,
  $pshard_stats       = false,
  $ssl_cert           = undef,
  $ssl_key            = undef,
  $ssl_verify         = true,
  $tags               = [],
  $url                = 'http://localhost:9200',
  $username           = undef,
  $instances          = undef
) inherits datadog_agent::params {
  include datadog_agent

  validate_array($tags)
  # $ssl_verify can be a bool or a string
  # https://github.com/DataDog/dd-agent/blob/master/checks.d/elastic.py#L454-L455
  if is_bool($ssl_verify) {
    validate_bool($ssl_verify)
  } elsif $ssl_verify != undef {
    validate_string($ssl_verify)
    validate_absolute_path($ssl_verify)
  }
  validate_bool($cluster_stats, $pending_task_stats, $pshard_stats)
  validate_string($password, $ssl_cert, $ssl_key, $url, $username)

  if !$instances and $url {
    $_instances = [{
      'cluster_stats'      => $cluster_stats,
      'password'           => $password,
      'pending_task_stats' => $pending_task_stats,
      'pshard_stats'       => $pshard_stats,
      'ssl_cert'           => $ssl_cert,
      'ssl_key'            => $ssl_key,
      'ssl_verify'         => $ssl_verify,
      'tags'               => $tags,
      'url'                => $url,
      'username'           => $username
    }]
  } elsif !$instances {
    $_instances = []
  } else {
    $_instances = $instances
  }

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/elastic.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/elastic.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0644',
    content => template('datadog_agent/agent-conf.d/elastic.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
