# Class: datadog_agent::ubuntu
#
# This class contains the DataDog agent installation mechanism for Ubuntu
#
# Parameters:
#
# $apt_key = 'currentkey'
#
# $agent_version = 'latest'
#
# $repo = 'datadog'
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# Class: datadog_agent::ubuntu::update_repo
#
# handles updating the apt-sources.list to add a datadog repo
#
class datadog_agent::ubuntu(
  $apt_key = 'C7A7DA52',
  $agent_version = 'latest',
  $repo = 'local'
) {
  if $repo == 'datadog' {
    include ::datadog_agent::ubuntu::update_repo
  }

  package { 'datadog-agent-base':
    ensure => absent,
    before => Package['datadog-agent'],
  }

  package { 'datadog-agent':
    ensure  => $agent_version,
  }

  service { 'datadog-agent':
    ensure    => $::datadog_agent::service_ensure,
    enable    => $::datadog_agent::service_enable,
    hasstatus => false,
    pattern   => 'dd-agent',
    require   => Package['datadog-agent'],
  }

}

# This should probably make use of puppetlabs::apt, though that opens a big can-o-worms
#
class datadog_agent::ubuntu::update_repo {

  ensure_packages(['apt-transport-https'])

  if !$::datadog_agent::skip_apt_key_trusting {
    exec { 'datadog_key':
      command => "/usr/bin/apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ${apt_key}",
      unless  => "/usr/bin/apt-key list | grep ${apt_key} | grep expires",
      before  => File['/etc/apt/sources.list.d/datadog.list'],
    }
  }

  file { '/etc/apt/sources.list.d/datadog.list':
    source  => 'puppet:///modules/datadog_agent/datadog.list',
    owner   => 'root',
    group   => 'root',
    notify  => Exec['datadog_apt-get_update'],
    require => Package['apt-transport-https'],
  }

  exec { 'datadog_apt-get_update':
    command     => '/usr/bin/apt-get update',
    refreshonly => true,
    tries       => 2, # https://bugs.launchpad.net/launchpad/+bug/1430011 won't get fixed until 16.04 xenial
    try_sleep   => 30,
  }

}
