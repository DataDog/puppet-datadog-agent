class datadog_agent::installer (
  String $hello = '',
) {
  file {
    '/var/log/test.yaml':
      ensure  => present,
      content => $hello,
      owner   => 'dd-agent',
      group   => 'dd-agent',
      mode    => '0644',
  }
}
