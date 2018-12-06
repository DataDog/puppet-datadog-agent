class datadog_agent (
  $api_key = '',
  $host = '',
  $histogram_percentiles = '',
  $logs = [],
  $service = 'catch_all'
) {
  $agent_version       = 'latest'
  $repo_uri            = "https://yum.datadoghq.com/stable/6/${::architecture}/"
  $dd_user             = 'dd-agent'
  $dd_group            = 'root'
  $package_name        = 'datadog-agent'
  $service_name        = 'datadog-agent'
  $service_ensure      = 'running'
  $service_enable      = true

  if $ec2_tag_service {
    $actual_service = $ec2_tag_service
  } elsif $ec2_tag_application {
    $actual_service = $ec2_tag_application
  } else {
    $actual_service = $service
  }

  yumrepo {'datadog':
    ensure   => absent,
  }

  yumrepo {'datadog5':
    ensure   => absent,
  }

  yumrepo {'datadog6':
    enabled  => 1,
    gpgcheck => 0,
    descr    => 'Datadog, Inc.',
    baseurl  => $repo_uri
  }
  
  Package { require => Yumrepo['datadog6']}

  package { 'datadog-agent-base':
    ensure => absent,
    before => Package[$package_name],
  }

  package { $package_name:
    ensure  => $agent_version,
  }

  service { $service_name:
    ensure    => $service_ensure,
    hasstatus => false,
    pattern   => 'dd-agent',
    require   => Package[$package_name],
    start     => 'initctl start datadog-agent || true',
    stop      => 'initctl stop datadog-agent || true',
    status    => 'initctl status datadog-agent || true',
    restart   => 'initctl restart datadog-agent || true';
  }
  
  file { '/etc/datadog-agent':
    ensure  => directory,
    purge   => false,
    recurse => true,
    force   => false,
    owner   => $dd_user,
    group   => $dd_group,
    notify  => Service[$service_name];
  }
  
  file { '/etc/datadog-agent/conf.d':
    ensure  => directory,
    purge   => false,
    recurse => true,
    force   => false,
    owner   => $dd_user,
    group   => $dd_group,
    notify  => Service[$service_name];
  }

  file { '/etc/datadog-agent/conf.d/carabiner.d':
    ensure  => directory,
    purge   => false,
    recurse => true,
    force   => false,
    owner   => $dd_user,
    group   => $dd_group,
    notify  => Service[$service_name];
  }
  
  file { '/etc/datadog-agent/conf.d/system_logs.d':
    ensure  => directory,
    purge   => false,
    recurse => true,
    force   => false,
    owner   => $dd_user,
    group   => $dd_group,
    notify  => Service[$service_name];
  }
  
  file { '/etc/datadog-agent/conf.d/custom_logs.d':
    ensure  => directory,
    purge   => false,
    recurse => true,
    force   => false,
    owner   => $dd_user,
    group   => $dd_group,
    notify  => Service[$service_name];
  }

  file { '/etc/datadog-agent/datadog.yaml':
    owner   => 'dd-agent',
    group   => 'dd-agent',
    mode    => '0640',
    ensure => present,
    notify  => Service[$service_name],
    content => template('datadog_agent/datadog.yaml.erb'),
    require => Package['datadog-agent'];
  }

  file { '/etc/datadog-agent/conf.d/carabiner.d/conf.yaml':
    owner   => 'dd-agent',
    group   => 'dd-agent',
    mode    => '0640',
    ensure => present,
    source => 'puppet:///modules/datadog_agent/carabiner_conf.yaml',
    notify  => Service[$service_name],
    require => Package['datadog-agent'];
  }
  
  file { '/etc/datadog-agent/conf.d/system_logs.d/conf.yaml':
    owner   => 'dd-agent',
    group   => 'dd-agent',
    mode    => '0640',
    ensure => present,
    source => 'puppet:///modules/datadog_agent/system_logs_conf.yaml',
    notify  => Service[$service_name],
    require => Package['datadog-agent'];
  }

  file { '/etc/datadog-agent/conf.d/custom_logs.d/conf.yaml':
    owner   => 'dd-agent',
    group   => 'dd-agent',
    mode    => '0640',
    ensure => present,
    notify  => Service[$service_name],
    content => template('datadog_agent/custom_logs.yaml.erb'),
    require => Package['datadog-agent'];
  }

  # Set initial permissions on log files
  exec { 'messages_permissions':
    command  => '/usr/bin/setfacl -m g:dd-agent:rx /var/log/messages || true',
    unless   => 'if [ -f /var/log/messages ] ; then if [ `getfacl /var/log/messages 2>/dev/null | sed -n -e 6p` != "group:dd-agent:r-x" ] ; then false ; fi ; fi',
    provider => shell;
  }
  exec { 'secure_permissions':
    command  => '/usr/bin/setfacl -m g:dd-agent:rx /var/log/secure || true',
    unless   => 'if [ -f /var/log/secure ] ; then if [ `getfacl /var/log/secure 2>/dev/null | sed -n -e 6p` != "group:dd-agent:r-x" ] ; then false ; fi ; fi',
    provider => shell;
  }
  exec { 'uwsgi_permissions':
    command  => '/usr/bin/setfacl -m g:dd-agent:rx /var/log/adroll/uwsgi.log || true',
    unless   => 'if [ -f /var/log/adroll/uwsgi.log ] ; then if [ `getfacl /var/log/adroll/uwsgi.log 2>/dev/null | sed -n -e 6p` != "group:dd-agent:r-x" ] ; then false ; fi ; fi',
    provider => shell;
  }
  exec { 'uwsgi-gk_permissions':
    command  => '/usr/bin/setfacl -m g:dd-agent:rx /var/log/adroll/uwsgi-gk.log || true',
    unless   => 'if [ -f /var/log/adroll/uwsgi-gk.log ] ; then if [ `getfacl /var/log/adroll/uwsgi-gk.log 2>/dev/null | sed -n -e 6p` != "group:dd-agent:r-x" ] ; then false ; fi ; fi',
    provider => shell;
  }
  exec { 'uwsgi-report_permissions':
    command  => '/usr/bin/setfacl -m g:dd-agent:rx /var/log/adroll/uwsgi-report.log || true',
    unless   => 'if [ -f /var/log/adroll/uwsgi-report.log ] ; then if [ `getfacl /var/log/adroll/uwsgi-report.log 2>/dev/null | sed -n -e 6p` != "group:dd-agent:r-x" ] ; then false ; fi ; fi',
    provider => shell;
  }
  exec { 'puppet_log_permissions':
    command  => '/usr/bin/setfacl -m g:dd-agent:rx /var/log/puppet/agent.log || true',
    unless   => 'if [ -f /var/log/puppet/agent.log ] ; then if [ `getfacl /var/log/puppet/agent.log 2>/dev/null | sed -n -e 6p` != "group:dd-agent:r-x" ] ; then false ; fi ; fi',
    provider => shell;
  }
  exec { 'puppet_dir_permissions':
    command  => '/usr/bin/setfacl -m g:dd-agent:rx /var/log/puppet || true',
    unless   => 'if [ -d /var/log/puppet ] ; then if [ `getfacl /var/log/puppet 2>/dev/null | sed -n -e 6p` != "group:dd-agent:r-x" ] ; then false ; fi ; fi',
    provider => shell;
  }

  # Sometimes the Datadog auth_token file becomes owned by root, chown it just in case
  exec { 'chown_auth_token':
    command => 'chown dd-agent /etc/datadog-agent/auth_token || true',
    unless  => 'if [ `stat -c %U  /etc/datadog-agent/auth_token` != "dd-agent" ] ; then false; fi',
    provider => shell,
    notify  => Service[$service_name];
  }
}
