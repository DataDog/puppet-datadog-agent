# Class: datadog_agent::integrations::logs
#
# This class will install the necessary configuration for the logs integration.
#
# Parameters:
#   $logs:
#       array of log sources.
#
# Log Source:
#   $type
#       Type of log input source (tcp / udp / file / docker / journald / windows_event).
#   $service
#       Optional name of the service owning the log.
#   $source
#       Optional attribute that defines which integration is sending the logs.
#   $tags
#       Optional tags that are added to each log collected.
#   $log_processing_rules
#       Optional array of processing rules.
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::logs' :
#    logs => [
#      {
#        'type' => 'file',
#        'path' => '/var/log/afile.log',
#      },
#      {
#        'type' => 'docker',
#      },
#    ],
# }
#
# Documentation:
# https://docs.datadoghq.com/logs/log_collection
#

class datadog_agent::integrations::logs(
  Boolean $hiera_logs = false,
  Array $logs = [],
) inherits datadog_agent::params {

  unless $::datadog_agent::agent5_enable {

    include datadog_agent

    validate_legacy('Boolean', 'validate_bool', $hiera_logs)
    validate_legacy('Array', 'validate_array', $logs)

    if $hiera_logs {
      $local_logs = lookup({ 'name' => 'datadog_agent::integrations::logs::logs', 'merge' => 'unique', 'default_value' => $logs })
    } else {
      $local_logs = $logs
    }

    # The Datadog documentation tells to create a conf.d/directory named after your log source, but for ease of use, we will put everything into conf.d/logs.d
    # https://docs.datadoghq.com/logs/log_collection/?tab=tailexistingfiles#custom-log-collection
    file { "${datadog_agent::conf6_dir}/logs.d":
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0750',
    }

    file { "${datadog_agent::conf6_dir}/logs.d/conf.yaml":
      ensure  => file,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0600',
      content => template('datadog_agent/agent-conf.d/logs.yaml.erb'),
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name]
    }

  }  # unless $::datadog_agent::agent5_enable

}
