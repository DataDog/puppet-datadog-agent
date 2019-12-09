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
  Optional[Array] $plugin_ids = [],
) inherits datadog_agent::params {
  include ::datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/fluentd.yaml"
  if $::datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/fluentd.d"
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
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/fluentd.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
