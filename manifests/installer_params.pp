# Class: datadog_agent::installer_params
#
# This class contains the Datadog installer parameters
#

class datadog_agent::installer_params (
  String $api_key = 'your_API_key',
  String $datadog_site = 'datadoghq.com',
  String $packages_to_install = 'datadog-agent',
) {
  $_service = 'datadog-puppet'
  $role_version = load_module_metadata($module_name)['version']
  $rc = -4
  $trace_id = -5
  $output = 'BOOTSTRAP COMMAND OUTPUT'
  # Template integers to be replaced with sed
  $start_time = -1
  $stop_time = -2
  $json_trace_body_hash = {
    'api_version'  => 'v2',
    'request_type' => 'traces',
    'tracer_time'  => $stop_time,
    'runtime_id'   => "${trace_id}",
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
      'language_name'    => 'puppet',
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
            'duration'   => -3,
            'error'      => $rc,
            'meta'       => {
              'language'                  => 'puppet',
              'exit_code'                 => $rc,
              'error'                     => {
                'message' => $output,
              },
              'version'                   => $role_version,
              'packages_to_install'        => $packages_to_install,
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
    # TO DO: replace -4 with the actual return code instead of hardcoded 0
    command => "echo \'${json_trace_body}\' > /tmp/trace_payload.json
      sed -i \"s/-1/$(cat /tmp/puppet_start_time)/g\" /tmp/trace_payload.json
      sed -i \"s/-2/$(cat /tmp/puppet_stop_time)/g\" /tmp/trace_payload.json
      sed -i \"s/-3/$(echo $(expr $(cat /tmp/puppet_stop_time) - $(cat /tmp/puppet_start_time)))/g\" /tmp/trace_payload.json
      sed -i \"s/-4/0/g\" /tmp/trace_payload.json
      sed -i \"s/-5/$(cat /tmp/datadog_trace_id)/g\" /tmp/trace_payload.json
      sed -i \"s/BOOTSTRAP COMMAND OUTPUT/TO BE REPLACED BY RETRIEVING STDOUT/g\" /tmp/trace_payload.json",
    path    => ['/usr/bin', '/bin'],
    onlyif  => ['which echo', 'which sed', 'which expr'],
  }
  exec { 'Send trace':
    command   => "curl -s -X POST -H 'Content-Type: application/json' -H 'DD-API-KEY: ${api_key}' -d '@/tmp/trace_payload.json' https://instrumentation-telemetry-intake.${datadog_site}/api/v2/apmtelemetry",
    path      => ['/usr/bin', '/bin'],
    onlyif    => 'which curl',
    logoutput => true,
    require   => Exec['Prepare trace payload replacing template values'],
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
          'message' => "Installer: ${rc} ${output}",
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
    command => "curl -s -X POST -H 'Content-Type: application/json' -H 'DD-API-KEY: ${api_key}' -d '@/tmp/log_payload.json' https://instrumentation-telemetry-intake.${datadog_site}/api/v2/apmtelemetry",
    path    => ['/usr/bin', '/bin'],
    onlyif  => 'which curl',
    require => Exec['Prepare log payload replacing template values'],
  }
}
