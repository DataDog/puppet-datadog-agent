# Class: datadog_agent::ubuntu::agent6
#
# This class contains the DataDog agent installation mechanism for Debian derivatives
#

class datadog_agent::ubuntu::agent6(
  String $apt_key = 'A2923DFF56EDA6E76E55E492D3A80E30382E94DE',
  String $agent_version = $datadog_agent::params::agent_version,
  String $location = $datadog_agent::params::agent6_default_repo,
  String $release = $datadog_agent::params::apt_default_release,
  String $repos = '6',
  Boolean $skip_apt_key_trusting = false,
  String $service_ensure = 'running',
  Boolean $service_enable = true,
  Optional[String] $service_provider = undef,
  Optional[String] $apt_keyserver = undef,
) inherits datadog_agent::params {

  ensure_packages(['apt-transport-https'])
  if !$skip_apt_key_trusting {
    ::datadog_agent::ubuntu::install_key { [$apt_key]:
      server => $apt_keyserver,
      before => Apt::Source['datadog6'],
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

  if $service_provider {
    service { $datadog_agent::params::service_name:
      ensure    => $service_ensure,
      enable    => $service_enable,
      provider  => $service_provider,
      hasstatus => false,
      pattern   => 'dd-agent',
      require   => Package['datadog-agent'],
    }
  } else {
    service { $datadog_agent::params::service_name:
      ensure    => $service_ensure,
      enable    => $service_enable,
      hasstatus => false,
      pattern   => 'dd-agent',
      require   => Package['datadog-agent'],
    }
  }
}
