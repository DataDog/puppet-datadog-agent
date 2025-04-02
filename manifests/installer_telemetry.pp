# This class handles the installation telemetry for the Datadog installer.
#
# @param api_key Sensitive[String]:Your DataDog API Key.
# @param datadog_site String: The site of the Datadog intake to send Agent data to. Defaults to 'datadoghq.com'.
# @param packages_to_install String: The packages to be installed by the Datadog installer.
#
class datadog_agent::installer_telemetry (
  Sensitive[String] $api_key = 'your_API_key',
  String $datadog_site = 'datadoghq.com',
  String $packages_to_install = 'datadog-agent',
) {
  $role_version = load_module_metadata($module_name)['version']

  file { 'Trace payload templating':
    ensure  => file,
    path    => '/tmp/trace_payload.json',
    content => epp('datadog_agent/installer/telemetry/trace.json.epp', {
        'role_version'        => $role_version,
        'packages_to_install' => $packages_to_install
      }
    ),
  }

  file { 'Log payload templating':
    ensure  => file,
    path    => '/tmp/log_payload.json',
    content => epp('datadog_agent/installer/telemetry/log.json.epp', {
        'role_version' => $role_version
      }
    ),
  }

  file { 'Telemetry script templating':
    ensure  => file,
    path    => '/tmp/datadog_send_telemetry.sh',
    content => epp('datadog_agent/installer/telemetry/send_telemetry.sh.epp', {
        'datadog_site' => $datadog_site,
        'api_key'      => $api_key
      }
    ),
    mode    => '0744',
    require => [
      File['Trace payload templating'],
      File['Log payload templating'],
    ],
  }

  exec { 'Run telemetry script':
    # We don't want to fail the installation if telemetry fails and we need to remove the script after running it, hence the semicolon
    command => 'bash /tmp/datadog_send_telemetry.sh ; rm -f /tmp/datadog_send_telemetry.sh',
    path    => ['/usr/bin', '/bin'],
    require => File['Telemetry script templating'],
  }
}
