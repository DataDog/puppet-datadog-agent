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
  $stop_time = 'your_stop_time_value'
  $role_version = 'your_role_version_value'
  $start_time = 'your_start_time_value'
  $rc = 'your_rc_value'
  $stderr = 'your_stderr_value'
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
            'duration'   => $stop_time - $start_time,
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
  $json_body = to_json($json_trace_body_hash)
  exec { 'Send trace':
    command   => "curl -v -X POST -H 'Content-Type: application/json' -H 'DD-API-KEY: ${api_key}' -d '${json_body}' https://instrumentation-telemetry-intake.${datadog_site}/api/v2/apmtelemetry",
    path      => ['/usr/bin', '/bin'],
    unless    => 'which curl',
    logoutput => true,
  }
}
