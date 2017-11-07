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
#

class datadog_agent::ubuntu(
  $apt_key = 'A2923DFF56EDA6E76E55E492D3A80E30382E94DE',
  $agent_version = 'latest',
  $other_keys = ['935F5A436A5A6E8788F0765B226AE980C7A7DA52'],
  $location = 'https://apt.datadoghq.com',
  $release = 'stable',
  $repos = 'main',
) {
  include apt

  ensure_packages(['apt-transport-https'])
  validate_array($other_keys)

  if !$::datadog_agent::skip_apt_key_trusting {
    $mykeys = concat($other_keys, [$apt_key])

    $mykeys.each | String $key | {
      apt::key { "dd-${key}":
        id     => $key,
        before => Apt::Source['datadog'],
      }
    }
  }

  file { '/etc/apt/sources.list.d/datadog.list':
    ensure => absent,
  }

  file { '/etc/apt/sources.list.d/datadog-beta.list':
    ensure => absent,
  }

  apt::source { 'datadog-apt':
    location => $location,
    release  => $release,
    repos    => $repos,
    notify   => Exec['datadog_apt-get_update'],
  }

  exec { 'datadog_apt-get_update':
    command     => '/usr/bin/apt-get update',
    refreshonly => true,
    tries       => 2, # https://bugs.launchpad.net/launchpad/+bug/1430011 won't get fixed until 16.04 xenial
    try_sleep   => 30,
  }

  package { 'datadog-agent':
    ensure  => $agent_version,
    require => [
      Apt::Source['datadog'],
      Exec['datadog_apt-get_update']
    ],
  }

  service { 'datadog-agent':
    ensure    => $::datadog_agent::service_ensure,
    enable    => $::datadog_agent::service_enable,
    hasstatus => false,
    pattern   => 'dd-agent',
    require   => Package['datadog-agent'],
  }
}
