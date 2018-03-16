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
  $url                    = 'localhost',
  $port                   = 11211,
  $tags                   = [],
  $items                  = false,
  $slabs                  = false,
  $instances = undef,
) inherits datadog_agent::params {
  include datadog_agent

  validate_string($url)
  validate_array($tags)
  validate_integer($port)

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

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/mcache.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/mcache.yaml"
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
