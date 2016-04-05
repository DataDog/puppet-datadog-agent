# Class: datadog_agent::redhat
#
# This class contains the DataDog agent installation mechanism for Red Hat derivatives
#
# Parameters:
#   $baseurl:
#       Baseurl for the datadog yum repo
#       Defaults to http://yum.datadoghq.com/rpm/${::architecture}/
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class datadog_agent::redhat(
  $baseurl = "https://yum.datadoghq.com/rpm/${::architecture}/",
  $gpgkey = 'https://yum.datadoghq.com/DATADOG_RPM_KEY.public',
  $manage_repo = true,
  $agent_version = 'latest'
) {

  validate_bool($manage_repo)
  if $manage_repo {
    validate_string($baseurl)

    yumrepo {'datadog':
      enabled  => 1,
      gpgcheck => 1,
      gpgkey   => $gpgkey,
      descr    => 'Datadog, Inc.',
      baseurl  => $baseurl,
    }

    Package { require => Yumrepo['datadog']}
  }

  package { 'datadog-agent-base':
    ensure => absent,
    before => Package['datadog-agent'],
  }

  package { 'datadog-agent':
    ensure  => $agent_version,
  }

  service { 'datadog-agent':
    ensure    => $::datadog_agent::service_ensure,
    enable    => $::datadog_agent::service_enable,
    hasstatus => false,
    pattern   => 'dd-agent',
    require   => Package['datadog-agent'],
  }

}
