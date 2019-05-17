# Class: datadog_agent::integrations::memcache
#
# This class will install the necessary configuration for the memcache integration
#
# Parameters:
#   $url:
#       url used to connect to the memcached instance
#   $port:
#   $tags
#       Optional array of tags
#
# Sample Usage:
#
# include 'datadog_agent::integrations::memcache'
#
# OR
#
# class { 'datadog_agent::integrations::memcache':
#   url      => 'localhost',
# }
#
#
# Sample Usage (Instance):
#  class { 'datadog_agent::integrations::memcache' :
#    instances => [{
#      url   => 'localhost',
#      port  => '11211',
#      items => false,
#      slabs => false,
#    }]
#  }
#
class datadog_agent::integrations::memcache (
  String $url                     = 'localhost',
  Variant[String, Integer] $port  = 11211,
  Array $tags                     = [],
  Variant[Boolean, String] $items = false,
  Variant[Boolean, String] $slabs = false,
  Optional[Array] $instances      = undef,
) inherits datadog_agent::params {
  include datadog_agent

  validate_legacy('String', 'validate_string', $url)
  validate_legacy('Array', 'validate_array', $tags)

  if !$instances and $url {
    $_instances = [{
      'url'   => $url,
      'port'  => $port,
      'tags'  => $tags,
      'items' => $items,
      'slabs' => $slabs,
    }]
  } elsif !$instances{
    $_instances = []
  } else {
    $_instances = $instances
  }

  $legacy_dst = "${datadog_agent::conf_dir}/mcache.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/mcache.d"
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
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/mcache.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
