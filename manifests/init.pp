class datadog_agent {
  $repo_uri            = "https://yum.datadoghq.com/stable/6/${::architecture}/"
  $conf6_dir           = '/etc/datadog-agent/conf.d'
  $dd_user             = 'dd-agent'
  $dd_group            = 'root'
  $package_name        = 'datadog-agent'
  $service_name        = 'datadog-agent'
  $service_ensure      = 'running'
  $service_enable      = true

  class { 'datadog_agent::redhat::agent6':
    baseurl          => $repo_uri,
    manage_repo      => $manage_repo,
    agent_version    => $agent_version,
    service_ensure   => $service_ensure,
    service_enable   => $service_enable,
    service_provider => $service_provider,
  }

  file { '/etc/datadog-agent':
    ensure  => directory,
    purge   => false,
    recurse => true,
    force   => false,
    owner   => $dd_user,
    group   => $dd_group,
    notify  => Service[$datadog_agent::params::service_name]
  }

  file { '/etc/datadog-agent/conf.d/carabiner.d':
    ensure  => directory,
    purge   => $false,
    recurse => true,
    force   => $false,
    owner   => $dd_user,
    group   => $dd_group,
  }
  
  file { '/etc/datadog-agent/conf.d/system_logs.d':
    ensure  => directory,
    purge   => $false,
    recurse => true,
    force   => $false,
    owner   => $dd_user,
    group   => $dd_group,
  }

  file { '/etc/datadog-agent/datadog.yaml':
      owner   => 'dd-agent',
      group   => 'dd-agent',
      mode    => '0640',
      ensure => present,
      source => 'puppet:///modules/datadog_agent/datadog.yaml',
      notify  => Service[$datadog_agent::params::service_name],
      require => Package['datadog-agent'];
    }
  }

  file { '/etc/datadog-agent/conf.d/carabiner.d/conf.yaml':
    ensure => present,
    source => 'puppet:///modules/datadog_agent/carabiner_conf.yaml',
    notify  => Service[$datadog_agent::params::service_name],
    require => Package['datadog-agent'];
  }
  
  file { '/etc/datadog-agent/conf.d/system_logs.d/conf.yaml':
    ensure => present,
    source => 'puppet:///modules/datadog_agent/system_logs_conf.yaml',
    notify  => Service[$datadog_agent::params::service_name],
    require => Package['datadog-agent'];
  }

  # Set initial permissions on log files
  exec { 'messages_permissions':
    command => '/usr/bin/setfacl -m g:dd-agent:rx /var/log/messages || true';
  }
  exec { 'secure_permissions':
    command => '/usr/bin/setfacl -m g:dd-agent:rx /var/log/secure || true';
  }
  exec { 'uwsgi_permissions':
    command => '/usr/bin/setfacl -m g:dd-agent:rx /var/log/adroll/uwsgi.log || true';
  }
  exec { 'uwsgi-gk_permissions':
    command => '/usr/bin/setfacl -m g:dd-agent:rx /var/log/adroll/uwsgi-gk.log || true';
  }
  exec { 'uwsgi-report_permissions':
    command => '/usr/bin/setfacl -m g:dd-agent:rx /var/log/adroll/uwsgi-report.log || true';
  }
}
