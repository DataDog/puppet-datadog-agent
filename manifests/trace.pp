class datadog_agent::trace() {
  yumrepo { 'datadog-trace':
    ensure   => present,
    baseurl  => 'http://yum-trace.datad0g.com.s3.amazonaws.com/x86_64/',
    enabled  => 1,
    priority => 1,
    gpgcheck => 0
  }

  package { 'dd-trace-agent':
    ensure  => present,
    require => Yumrepo['datadog-trace']      
  }

  service { 'dd-trace-agent':
    ensure => running,
    enable => true,
    require => Package['dd-trace-agent']
  }  
}
