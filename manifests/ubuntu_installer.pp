class datadog_agent::ubuntu_installer (
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
