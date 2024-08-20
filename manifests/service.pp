# Class: datadog_agent::service
#
# This class declares the datadog-agent service
#

class datadog_agent::service(
  $service_ensure = 'running',
  Variant[Boolean, Enum['manual', 'mask', 'delayed']] $service_enable = true,
  Optional[String] $service_provider = undef,
  String $agent_flavor = $datadog_agent::params::package_name,
) inherits datadog_agent::params {
  if $service_provider {
    service { $datadog_agent::params::service_name:
      ensure    => $service_ensure,
      enable    => $service_enable,
      provider  => $service_provider,
      hasstatus => false,
      pattern   => 'dd-agent',
      require   => Package[$agent_flavor],
    }
  } else {
    service { $datadog_agent::params::service_name:
      ensure    => $service_ensure,
      enable    => $service_enable,
      hasstatus => false,
      pattern   => 'dd-agent',
      require   => Package[$agent_flavor],
    }
  }
}
