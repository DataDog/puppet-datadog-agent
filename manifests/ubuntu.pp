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
) inherits datadog_agent::params{

  ensure_packages(['apt-transport-https'])
  validate_array($other_keys)

  if !$::datadog_agent::skip_apt_key_trusting {
    $mykeys = concat($other_keys, [$apt_key])

    ::datadog_agent::ubuntu::install_key { $mykeys:
      before  => File['/etc/apt/sources.list.d/datadog.list'],
    }
  }

  # This is a hack - I'm not happy about it, but we should rarely
  # hit this code path
  #
  # Also, using $::apt_agent6_beta_repo to access fact instead of
  # $facts hash - for compatibility with puppet3.x default behavior
  if $::apt_agent6_beta_repo and $agent_version == 'latest' {
    exec { 'datadog_apt-get_remove_agent6':
      command => '/usr/bin/apt-get remove -y -q datadog-agent',
      onlyif  => '/usr/bin/dpkg -l datadog-agent > /dev/null'
    }
  } else {
    exec { 'datadog_apt-get_remove_agent6':
      command     => ':',  # NOOP builtin
      noop        => true,
      refreshonly => true,
      provider    => 'shell',
    }
  }

  if $::apt_agent6_beta_repo {
    file { '/etc/apt/sources.list.d/datadog-beta.list':
      ensure => absent,
    }
  }

  file { '/etc/apt/sources.list.d/datadog.list':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => template('datadog_agent/datadog.list.erb'),
    notify  => [Exec['datadog_apt-get_remove_agent6'],
                Exec['datadog_apt-get_update']],
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
    before => Package[$datadog_agent::params::package_name],
  }

  package { $datadog_agent::params::package_name:
    ensure  => $agent_version,
    require => [File['/etc/apt/sources.list.d/datadog.list'],
                Exec['datadog_apt-get_update']],
  }

  service { $datadog_agent::params::service_name:
    ensure    => $::datadog_agent::service_ensure,
    enable    => $::datadog_agent::service_enable,
    hasstatus => false,
    pattern   => "^(dd|datadog)-agent",
    require   => Package[$datadog_agent::params::package_name],
  }
}
