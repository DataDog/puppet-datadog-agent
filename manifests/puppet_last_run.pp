class datadog_agent::puppet_last_run {
  file {'/etc/dd-agent/conf.d/':
    ensure => directory,
    owner  => 'dd-agent'
    } ->
  file {'/etc/dd-agent/checks.d/':
    ensure => directory,
    owner  => 'dd-agent',
    } ->

  file { '/etc/dd-agent/checks.d/puppet_last_run.py':
    ensure  => file,
    owner  => 'dd-agent',
    source  => 'puppet:///modules/datadog_agent/puppet_last_run.py',
    notify  => Service['datadog-agent'],
  } ->
  file { '/etc/dd-agent/conf.d/puppet_last_run.yaml':
    ensure  => file,
    content => template('datadog_agent/puppet_last_run.yaml.erb'),
    owner   => 'dd-agent',
    notify  => Service['datadog-agent'],
  }
}