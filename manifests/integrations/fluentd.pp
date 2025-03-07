# Class: datadog_agent::integrations::fluentd
#
# This class will install the fluentd integration
#
# See the sample fluentd.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/fluentd/datadog_checks/fluentd/data/conf.yaml.example
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
class datadog_agent::integrations::fluentd (
  String $monitor_agent_url = 'http://localhost:24220/api/plugins.json',
  Array $plugin_ids         = [],
) inherits datadog_agent::params {
  require datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/fluentd.d"

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
    content => template('datadog_agent/agent-conf.d/fluentd.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
