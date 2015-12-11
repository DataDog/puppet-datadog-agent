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
class datadog_agent::ubuntu(
  $apt_key = 'C7A7DA52'
) {

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
  }

  package { 'datadog-agent-base':
    ensure => absent,
    before => Package['datadog-agent'],
  }

  package { 'datadog-agent':
    ensure  => latest,
    require => [File['/etc/apt/sources.list.d/datadog.list'],
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
