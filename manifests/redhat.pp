# Class: datadog_agent::redhat
#
# This class contains the DataDog agent installation mechanism for Red Hat derivatives
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class datadog_agent::redhat {

    yumrepo {'datadog':
      enabled  => 1,
      gpgcheck => 0,
      descr    => 'Datadog, Inc.',
      baseurl  => "http://yum.datadoghq.com/rpm/${::architecture}/",
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
