# Class: datadog::redhat
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
class datadog::redhat {

    yumrepo {'datadog':
      enabled   => 1,
      gpgcheck  => 0,
      descr     => 'Datadog, Inc.',
      baseurl   => 'http://apt.datadoghq.com/rpm/',
    }

    package { 'datadog-agent':
      ensure  => latest,
      require => Yumrepo['datadog'],
    }

    service { "datadog-agent":
      ensure    => running,
      enable    => true,
      hasstatus => false,
      pattern   => 'dd-agent',
      require   => Package["datadog-agent"],
    }

}
