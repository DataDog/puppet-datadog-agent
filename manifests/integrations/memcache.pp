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
  require ::datadog_agent

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

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/mcache.yaml"
  if $::datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/mcache.d"
    file { $legacy_dst:
      ensure => 'absent'
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::dd_user,
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
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/mcache.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
