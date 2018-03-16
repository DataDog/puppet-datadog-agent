# Class: datadog_agent::integrations::riak
#
# This class will install the necessary configuration for the riak integration
#
# Parameters:
#   $url:
#     The URL for riak
#   $tags
#       Optional array of tags
#
# Sample Usage:
#
#   include 'datadog_agent::integrations::riak'
#
#   OR
#
#   class { 'datadog_agent::integrations::riak' :
#     url   => 'http://localhost:8098/stats',
#   }
#
class datadog_agent::integrations::riak(
  $url   = 'http://localhost:8098/stats',
  $tags  = [],
) inherits datadog_agent::params {
  include datadog_agent

  validate_string($url)
  validate_array($tags)

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/riak.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/riak.yaml"
  }

  file {
    $dst:
      ensure  => file,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0644',
      content => template('datadog_agent/agent-conf.d/riak.yaml.erb'),
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name]
  }
}
