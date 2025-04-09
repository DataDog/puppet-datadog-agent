node default {
  class { 'datadog_agent':
    api_key                       => Sensitive('somenonnullapikeythats32charlong'),
    manage_install                => false,
    datadog_installer_enabled     => true,
    apm_instrumentation_enabled   => 'host',
    apm_instrumentation_libraries => ['java:1', 'python:2'],
    remote_updates                => false,
  }
}
