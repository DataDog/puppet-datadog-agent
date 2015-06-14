# Class: datadog_agent::ubuntu
#
# This class contains the DataDog agent installation mechanism for Ubuntu
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class datadog_agent::ubuntu {

  apt::source {
    'datadog':
      ensure      => 'present',
      location    => 'http://apt.datadoghq.com',
      release     => 'stable',
      repos       => 'main',
      include     => {
        'src'     => false,
      },
      key         => {
        id        => $::datadog::apt_key,
        server    => $::datadog::keyserver,
      },
      before      => Package['datadog-agent']
  }

  package {
    'datadog-agent-base':
      ensure => absent,
      before => Package['datadog-agent'],
  }

  package {
    'datadog-agent':
      ensure  => $::datadog_agent::version,
  }

  service {
    'datadog-agent':
      ensure    => $::datadog_agent::service_ensure,
      enable    => $::datadog_agent::service_enable,
      hasstatus => false,
      pattern   => 'dd-agent',
      require   => Package['datadog-agent'],
  }
}
