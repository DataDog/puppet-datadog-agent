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
  $cluster_stats                       = false,
  Optional[String] $password           = undef,
  $pending_task_stats                  = true,
  $pshard_stats                        = false,
  Optional[String] $ssl_cert           = undef,
  Optional[String] $ssl_key            = undef,
  Variant[Boolean, String] $ssl_verify = true,
  $tags                                = [],
  $url                                 = 'http://localhost:9200',
  Optional[String] $username           = undef,
  $instances                           = undef
) inherits datadog_agent::params {
  include datadog_agent

  validate_legacy(Array, 'validate_array', $tags)
  # $ssl_verify can be a bool or a string
  # https://github.com/DataDog/dd-agent/blob/master/checks.d/elastic.py#L454-L455
  if validate_legacy('Variant[Boolean, String]', 'is_string', $ssl_verify){
    validate_absolute_path($ssl_verify)
  }


  validate_legacy('Boolean', 'validate_bool', $cluster_stats)
  validate_legacy('Boolean', 'validate_bool', $pending_task_stats)
  validate_legacy('Boolean', 'validate_bool', $pshard_stats)

  validate_legacy('Optional[String]', 'validate_string', $password)
  validate_legacy('Optional[String]', 'validate_string', $ssl_cert)
  validate_legacy('Optional[String]', 'validate_string', $ssl_key)
  validate_legacy('Optional[String]', 'validate_string', $username)

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

  $legacy_dst = "${datadog_agent::conf_dir}/elastic.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/elastic.d"
    file { $legacy_dst:
      ensure => 'absent'
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0755',
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
    mode    => '0644',
    content => template('datadog_agent/agent-conf.d/elastic.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
