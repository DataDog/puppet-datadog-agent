# Class: datadog_agent::integrations::fluentd
#
# This class will install the fluentd integration
#
# Parameters:
#   $monitor_agent_url
#       The url fluentd lists it's plugins on
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::fluentd' :
#    monitor_agent_url     => 'http://localhost:24220/api/plugins.json',
#    plugin_ids => [
#     'elasticsearch_out',
#     'rsyslog_in',
#   ],
#  }
#
#
class datadog_agent::integrations::fluentd(
  $monitor_agent_url = 'http://localhost:24220/api/plugins.json',
  $plugin_ids = [],
) inherits datadog_agent::params {
  include ::datadog_agent

  validate_array($plugin_ids)

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/fluentd.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/fluentd.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/fluentd.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
