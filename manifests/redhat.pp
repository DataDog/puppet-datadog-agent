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
  $baseurl = "http://yum.datadoghq.com/rpm/${::architecture}/"
) {
    validate_string($baseurl)

    yumrepo {'datadog':
      enabled  => 1,
      gpgcheck => 0,
      descr    => 'Datadog, Inc.',
      baseurl  => $baseurl,
    }

    package { 'datadog-agent-base':
      ensure => absent,
      before => Package['datadog-agent'],
    }

    package { 'datadog-agent':
      ensure  => latest,
      require => Yumrepo['datadog'],
    }

    service { 'datadog-agent':
      ensure    => $::datadog_agent::service_ensure,
      enable    => $::datadog_agent::service_enable,
      hasstatus => false,
      pattern   => 'dd-agent',
      require   => Package['datadog-agent'],
    }

}
