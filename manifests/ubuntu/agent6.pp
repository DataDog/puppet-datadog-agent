# Class: datadog_agent::ubuntu::agent6
#
# This class contains the DataDog agent installation mechanism for Debian derivatives
#

class datadog_agent::ubuntu::agent6(
  $apt_key = 'A2923DFF56EDA6E76E55E492D3A80E30382E94DE',
  $agent_version = 'latest',
  $other_keys = ['935F5A436A5A6E8788F0765B226AE980C7A7DA52'],
  $location = $datadog_agent::params::agent6_default_repo,
  $release = 'stable',
  $repos = '6',
  $skip_apt_key_trusting = false,
  $service_ensure = 'running',
  $service_enable = true,
) inherits datadog_agent::params {

  ensure_packages(['apt-transport-https'])
  validate_array($other_keys)

  if !$skip_apt_key_trusting {
    $mykeys = concat($other_keys, [$apt_key])

    ::datadog_agent::ubuntu::install_key { $mykeys:
      before  => Apt::Source['datadog6'],
    }
  }

  apt::source { 'datadog':
    ensure => absent,
  }

  apt::source { 'datadog6':
    comment  => 'Datadog Agent 6 Repository',
    location => $location,
    release  => $release,
    repos    => $repos,
    require  => Package['apt-transport-https'],
    notify   =>  Exec['apt_update'],
  }

  package { 'datadog-agent-base':
    ensure => absent,
    before => Package['datadog-agent'],
  }

  package { $datadog_agent::params::package_name:
    ensure  => $agent_version,
    require => [Apt::Source['datadog6'],
                Exec['apt_update']],
  }

  service { $datadog_agent::params::service_name:
    ensure    => $service_ensure,
    enable    => $service_enable,
    hasstatus => false,
    pattern   => 'dd-agent',
    require   => Package['datadog-agent'],
  }
}
