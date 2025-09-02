# Class: datadog_agent::service
#
# This class declares the datadog-agent service
#
class datadog_agent::service (
  String $service_ensure = 'running',
  Variant[Boolean, Enum['manual', 'mask', 'delayed']] $service_enable = true,
  Optional[String] $service_provider = undef,
  String $agent_flavor = $datadog_agent::params::package_name,
) inherits datadog_agent::params {
  if ($facts['os']['name'] == 'Windows') {
    service { $datadog_agent::params::service_name:
      ensure  => $service_ensure,
      enable  => $service_enable,
      restart => ['powershell', '-Command', 'Restart-Service -Force DatadogAgent'], # Force restarts dependent services
      require => Package[$datadog_agent::params::package_name],
    }
  } else {
    # If `datadog-agent-exp` is active, skip service actions and exit early
    $exp_guard_cmd = 'if command -v systemctl >/dev/null 2>&1; then systemctl is-active --quiet datadog-agent-exp && exit 0; fi; if command -v service >/dev/null 2>&1; then service datadog-agent-exp status >/dev/null 2>&1 && exit 0; fi; pgrep -f datadog-packages/datadog-agent/experiment/bin/agent/agent >/dev/null 2>&1 && exit 0;'

    if $service_provider {
      service { $datadog_agent::params::service_name:
        ensure    => $service_ensure,
        enable    => $service_enable,
        provider  => $service_provider,
        hasstatus => false,
        pattern   => 'dd-agent',
        # Avoid starting the Agent if a remote update is in progress (exp guard cmd terminates the whole command)
        start     => ['/bin/sh', '-c', "${exp_guard_cmd} systemctl start datadog-agent 2>/dev/null || service datadog-agent start 2>/dev/null || /bin/true"],
        # Avoid restarting the Agent if a remote update is in progress (exp guard cmd terminates the whole command)
        restart   => ['/bin/sh', '-c', "${exp_guard_cmd} systemctl restart datadog-agent 2>/dev/null || service datadog-agent restart 2>/dev/null || /bin/true"],
        require   => Package[$agent_flavor],
      }
    } else {
      service { $datadog_agent::params::service_name:
        ensure    => $service_ensure,
        enable    => $service_enable,
        hasstatus => false,
        pattern   => 'dd-agent',
        # Avoid starting the Agent if a remote update is in progress (exp guard cmd terminates the whole command)
        start     => ['/bin/sh', '-c', "${exp_guard_cmd} systemctl start datadog-agent 2>/dev/null || service datadog-agent start 2>/dev/null || /bin/true"],
        # Avoid restarting the Agent if a remote update is in progress (exp guard cmd terminates the whole command)
        restart   => ['/bin/sh', '-c', "${exp_guard_cmd} systemctl restart datadog-agent 2>/dev/null || service datadog-agent restart 2>/dev/null || /bin/true"],
        require   => Package[$agent_flavor],
      }
    }
  }
}
