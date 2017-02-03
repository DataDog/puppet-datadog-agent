class datadog_agent::trace() {
  yumrepo { 'datadog-trace':
    ensure   => absent,
    baseurl  => 'http://yum-trace.datad0g.com.s3.amazonaws.com/x86_64/',
    enabled  => 1,
    priority => 1,
    gpgcheck => 1,
    gpgkey   => 'https://yum.datadoghq.com/DATADOG_RPM_KEY.public.E09422B3',
  }

  package { 'dd-trace-agent':
    ensure  => absent,
    require => Service['dd-trace-agent']
  }

  service { 'dd-trace-agent':
    ensure => stopped,
    enable => false,
  }  
}
