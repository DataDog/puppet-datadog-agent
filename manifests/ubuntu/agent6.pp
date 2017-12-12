# Class: datadog_agent::ubuntu::agent6
#
# This class contains the DataDog agent installation mechanism for Debian derivatives
#

class datadog_agent::ubuntu::agent6(
  $apt_key = 'A2923DFF56EDA6E76E55E492D3A80E30382E94DE',
  $agent_version = 'latest',
  $other_keys = ['935F5A436A5A6E8788F0765B226AE980C7A7DA52'],
  $location = 'https://apt.datadoghq.com',
  $release = 'beta',
  $repos = 'main',
) {

  ensure_packages(['apt-transport-https'])
  validate_array($other_keys)

  if !$::datadog_agent::skip_apt_key_trusting {
    $mykeys = concat($other_keys, [$apt_key])

    ::datadog_agent::ubuntu::install_key { $mykeys:
      before  => File['/etc/apt/sources.list.d/datadog-beta.list'],
    }

  }

  file { '/etc/apt/sources.list.d/datadog.list':
    ensure => absent,
  }

  file { '/etc/apt/sources.list.d/datadog-beta.list':
    owner   => 'root',
    group   => 'root',
    content => template('datadog_agent/datadog.list.erb'),
    notify  => Exec['datadog_apt-get_update'],
    require => Package['apt-transport-https'],
  }

  exec { 'datadog_apt-get_update':
    command     => '/usr/bin/apt-get update',
    refreshonly => true,
    tries       => 2, # https://bugs.launchpad.net/launchpad/+bug/1430011 won't get fixed until 16.04 xenial
    try_sleep   => 30,
    require     => File['/etc/apt/sources.list.d/datadog.list'],
  }

  package { 'datadog-agent-base':
    ensure => absent,
    before => Package['datadog-agent'],
  }

  package { 'datadog-agent':
    ensure  => $agent_version,
    require => [File['/etc/apt/sources.list.d/datadog-beta.list'],
                Exec['datadog_apt-get_update']],
  }

  service { 'datadog-agent':
    ensure    => $::datadog_agent::service_ensure,
    enable    => $::datadog_agent::service_enable,
    hasstatus => false,
    pattern   => 'dd-agent',
    require   => Package['datadog-agent'],
  }
}
