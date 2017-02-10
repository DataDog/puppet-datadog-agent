class datadog_agent::trace() {
  file { 'dd_trace_repo':
    path   => '/etc/yum.repos.d/datadog-trace.repo',
    ensure => absent
  }

  package { 'dd-trace-agent':
    ensure  => absent
  }

  service { 'dd-trace-agent':
    ensure => stopped,
    enable => false,
  }  
}
