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

  package { 'apt-transport-https':
    ensure => latest
  }

  apt::source {
    'datadog':
      ensure   => 'present',
      location => 'http://apt.datadoghq.com',
      release  => 'stable',
      repos    => 'main',
      include  => {
        'src' => false,
      },
      key      => {
        id     => 'C7A7DA52',
        server => 'pgp.mit.edu',
      },
      before   => [ Package['datadog-agent'],
        Package['apt-transport-https'] ]
  }

  package {
    'datadog-agent-base':
      ensure => absent,
      before => Package['datadog-agent'],
  }

  package {
    'datadog-agent':
      ensure  => 'latest',
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
