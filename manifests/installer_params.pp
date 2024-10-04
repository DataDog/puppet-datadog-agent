# Class: datadog_agent::installer_params
#
# This class contains the Datadog installer parameters
#

class datadog_agent::installer_params (
  String $api_key = 'your_API_key',
  String $datadog_site = 'datadoghq.com',
  Integer $trace_id = 1,
) {
  $_service = 'datadog-puppet'
  $role_version = 'your_role_version_value'
  $rc = 'your_rc_value'
  $stderr = 'your_stderr_value'
  # Template integers to be replaced with sed
  $start_time = -9990
  $stop_time = -9991
  $packages_to_install = 'your_packages_to_install_value'
  $packages_to_install_filtered = 'your_packages_to_install_filtered_value'
  $json_trace_body_hash = {
    'api_version'  => 'v2',
    'request_type' => 'traces',
    'tracer_time'  => $stop_time,
    'runtime_id'   => $trace_id,
    'seq_id'       => 1,
    'origin'       => 'puppet',
    'host'         => {
      'hostname'        => $hostname,
      'os'              => $facts['os']['name'],
      'distribution'    => $facts['os']['family'],
      'architecture'    => $facts['os']['architecture'],
      'kernel_version'  => $facts['kernelversion'],
      'kernel_release'  => $facts['kernelrelease'],
    },
    'application'  => {
      'service_name'     => $_service,
      'service_version'  => $role_version,
      'language_name'    => 'UNKNOWN',
      'language_version' => 'n/a',
      'tracer_version'   => 'n/a',
    },
    'payload'      => {
      'traces' => [
        [
          {
            'service'    => $_service,
            'name'       => 'install_installer',
            'resource'   => 'install_installer',
            'trace_id'   => $trace_id,
            'span_id'    => $trace_id,
            'parent_id'  => 0,
            'start'      => $start_time,
            # TO DO: check duration calculation, diff between start and stop
            'duration'   => -9992,
            'error'      => $rc,
            'meta'       => {
              'language'                  => 'yaml',
              'exit_code'                 => $rc,
              'error'                     => {
                'message' => $stderr,
              },
              'version'                   => $role_version,
              'packages_to_install'        => $packages_to_install,
              'packages_to_install_after_installer' => $packages_to_install_filtered,
            },
            'metrics'    => {
              '_trace_root'            => 1,
              '_top_level'             => 1,
              '_dd.top_level'          => 1,
              '_sampling_priority_v1'  => 2,
            },
          },
        ],
      ],
    },
  }
  $json_trace_body = to_json($json_trace_body_hash)
  # We use this "hack" to replace the template values in the JSON payload as we can't use Puppet variables dynamically based on file contents
  exec { 'Prepare trace payload replacing template values':
    command => "echo \'${json_trace_body}\' > /tmp/trace_payload.json
      sed -i \"s/-9990/$(cat /tmp/puppet_start_time)/\" /tmp/trace_payload.json
      sed -i \"s/-9992/$(($(cat /tmp/puppet_stop_time) - $(cat /tmp/puppet_start_time)))/\" /tmp/trace_payload.json
      sed -i \"s/-9991/$(cat /tmp/puppet_stop_time)/\" /tmp/trace_payload.json",
    path    => ['/usr/bin', '/bin'],
    onlyif  => ['which echo', 'which sed'],
  }
  exec { 'Send trace':
    command   => "curl -s -X POST -H 'Content-Type: application/json' -H 'DD-API-KEY: ${api_key}' -d '${json_trace_body}' https://instrumentation-telemetry-intake.${datadog_site}/api/v2/apmtelemetry",
    path      => ['/usr/bin', '/bin'],
    onlyif    => 'which curl',
    logoutput => true,
  }
  $json_logs_body_hash = {
    'api_version'  => 'v2',
    'request_type' => 'logs',
    'tracer_time'  => $stop_time,
    'runtime_id'   => $trace_id,
    'seq_id'       => 2,
    'origin'       => 'puppet',
    'host'         => {
      'hostname'        => $hostname,
      'os'              => $facts['os']['name'],
      'distribution'    => $facts['os']['family'],
      'architecture'    => $facts['os']['architecture'],
      'kernel_version'  => $facts['kernelversion'],
      'kernel_release'  => $facts['kernelrelease'],
    },
    'application'  => {
      'service_name'     => $_service,
      'service_version'  => $role_version,
      'language_name'    => 'UNKNOWN',
      'language_version' => 'n/a',
      'tracer_version'   => 'n/a',
    },
    'payload'      => {
      'logs' => [
        {
          'message' => "Installer: ${rc} ${stderr}",
          'status'  => 'INFO',
          'ddsource' => 'puppet',
          'ddtags'   => 'category:installer',
        },
      ],
    },
  }
  $json_logs_body = to_json($json_logs_body_hash)
  exec { 'Prepare log payload replacing template values':
    command => "echo \'${json_logs_body}\' > /tmp/log_payload.json
      sed -i \"s/-9991/$(cat /tmp/puppet_stop_time)/\" /tmp/log_payload.json",
    path    => ['/usr/bin', '/bin'],
    onlyif  => ['which echo', 'which sed'],
  }
  exec { 'Send logs':
    command   => "curl -v -X POST -H 'Content-Type: application/json' -H 'DD-API-KEY: ${api_key}' -d '${json_logs_body}' https://instrumentation-telemetry-intake.${datadog_site}/api/v2/apmtelemetry",
    path      => ['/usr/bin', '/bin'],
    onlyif    => 'which curl',
    logoutput => true,
  }
}
