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
  Boolean $cluster_stats               = false,
  Boolean $index_stats                 = false,
  Optional[String] $password           = undef,
  Boolean$pending_task_stats           = true,
  Boolean $pshard_stats                = false,
  Optional[String] $ssl_cert           = undef,
  Optional[String] $ssl_key            = undef,
  Variant[Boolean, String] $ssl_verify = true,
  Array $tags                          = [],
  String $url                          = 'http://localhost:9200',
  Optional[String] $username           = undef,
  Optional[Array] $instances           = undef
) inherits datadog_agent::params {
  require ::datadog_agent

  # $ssl_verify can be a bool or a string
  # https://github.com/DataDog/dd-agent/blob/master/checks.d/elastic.py#L454-L455
  if validate_legacy('Variant[Boolean, String]', 'is_string', $ssl_verify){
    validate_absolute_path($ssl_verify)
  }

  if !$instances and $url {
    $_instances = [{
      'cluster_stats'      => $cluster_stats,
      'index_stats'        => $index_stats,
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

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/elastic.yaml"
  if $::datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/elastic.d"
    file { $legacy_dst:
      ensure => 'absent'
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
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
    mode    => $datadog_agent::params::permissions_file,
    content => template('datadog_agent/agent-conf.d/elastic.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
