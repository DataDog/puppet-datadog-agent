# Class: datadog_agent::service
#
# This class declares the datadog-agent service
#

class datadog_agent::service(
  $service_ensure = 'running',
  Boolean $service_enable = true,
  Optional[String] $service_provider = undef,
) inherits datadog_agent::params {

  if ($::operatingsystem == 'Windows') {
      service { $datadog_agent::params::service_name:
        ensure  => $service_ensure,
        enable  => $service_enable,
        restart => ['powershell', '-Command', 'Restart-Service -Force DatadogAgent'], # Force restarts dependent services
        require => Package[$datadog_agent::params::package_name]
      }
  } else {
    if $service_provider {
      service { $datadog_agent::params::service_name:
        ensure    => $service_ensure,
        enable    => $service_enable,
        provider  => $service_provider,
        hasstatus => false,
        pattern   => 'dd-agent',
        require   => Package[$datadog_agent::params::package_name],
      }
    } else {
      service { $datadog_agent::params::service_name:
        ensure    => $service_ensure,
        enable    => $service_enable,
        hasstatus => false,
        pattern   => 'dd-agent',
        require   => Package[$datadog_agent::params::package_name],
      }
    }
  }


}
