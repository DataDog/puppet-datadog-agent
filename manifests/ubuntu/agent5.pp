# Class: datadog_agent::ubuntu
#
# This class contains the DataDog agent installation mechanism for Ubuntu
#

class datadog_agent::ubuntu::agent5(
  String $apt_key = 'A2923DFF56EDA6E76E55E492D3A80E30382E94DE',
  String $agent_version = $datadog_agent::params::agent_version,
  Optional[String] $agent_repo_uri = undef,
  String $release = $datadog_agent::params::apt_default_release,
  String $repos = 'main',
  Boolean $skip_apt_key_trusting = false,
  String $service_ensure = 'running',
  Boolean $service_enable = true,
  Optional[String] $service_provider = undef,
  Optional[String] $apt_keyserver = undef,
) inherits datadog_agent::params {

  if !$skip_apt_key_trusting {
    $key = {
      'id' => $apt_key,
      'server' => $apt_keyserver,
    }
  } else {
    $key = {}
  }

  if ($agent_repo_uri != undef) {
    $location = $agent_repo_uri
  } else {
    $location = 'https://apt.datadoghq.com'
  }

  # This is a hack - I'm not happy about it, but we should rarely
  # hit this code path. We can't use 'Package' because we later have
  # to ensure datadog-agent is present.

  if ($facts['apt_agent6_beta_repo'] or $facts['apt_agent6_repo']) and $agent_version == 'latest' {
    exec { 'datadog_apt-get_remove_agent6':
      command     => '/usr/bin/apt-get remove -y -q datadog-agent',
    }
  } else {
    exec { 'datadog_apt-get_remove_agent6':
      command     => ':',  # NOOP builtin
      noop        => true,
      refreshonly => true,
      provider    => 'shell',
    }
  }

  if $facts['apt_agent6_beta_repo'] {
    apt::source { 'datadog-beta':
      ensure => absent,
    }
  }
  if $facts['apt_agent6_repo'] {
    apt::source { 'datadog6':
      ensure => absent,
    }
  }

  apt::source { 'datadog':
    comment  => 'Datadog Agent Repository',
    location => $location,
    release  => $release,
    repos    => $repos,
    require  => Class['apt'],
    key      => $key,
    notify   => Exec['datadog_apt-get_remove_agent6'],
  }

  package { 'datadog-agent-base':
    ensure => absent,
    before => Package[$datadog_agent::params::package_name],
  }

  package { $datadog_agent::params::package_name:
    ensure  => $agent_version,
    require => [Apt::Source['datadog'],
                Class['apt::update']],
  }

  if $service_provider {
    service { $datadog_agent::params::service_name:
      ensure    => $service_ensure,
      enable    => $service_enable,
      provider  => $service_provider,
      hasstatus => false,
      pattern   => 'dd-agent',
      require   => Package[$datadog_agent::params::package_name],
    }
  } else {
    service { $datadog_agent::params::service_name:
      ensure    => $service_ensure,
      enable    => $service_enable,
      hasstatus => false,
      pattern   => 'dd-agent',
      require   => Package[$datadog_agent::params::package_name],
    }
  }
}
