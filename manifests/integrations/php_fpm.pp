# Class: datadog_agent::integrations::php_fpm
#
# This class will set-up PHP FPM monitoring
#
# Parameters:
#   $status_url
#        URL to fetch FPM metrics. Default: http://localhost/status
#
#   $ping_url
#        URL to get a reliable check of the FPM pool. Default: http://localhost/ping
#
#   $ping_reply
#        Expected response from ping_url. Default: pong
#
#   $tags
#        Optional array of tags
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::php_fpm' :
#    status_url     => 'http://localhost/fpm_status',
#    ping_url       => 'http://localhost/fpm_ping'
#  }
#

class datadog_agent::integrations::php_fpm(
  $status_url       = 'http://localhost/status',
  $ping_url         = 'http://localhost/ping',
  $ping_reply       = 'pong',
  $http_host        = undef,
  $tags             = [],
  $instances        = undef
) inherits datadog_agent::params {
  include datadog_agent

  if !$instances {
    $_instances = [{
      'http_host' => $http_host,
      'status_url' => $status_url,
      'ping_url' => $ping_url,
      'ping_reply' => $ping_reply,
      'tags' => $tags,
    }]
  } else {
    $_instances = $instances
  }

  $legacy_dst = "${datadog_agent::conf_dir}/php_fpm.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/php_fpm.d"
    file { $legacy_dst:
      ensure => 'absent'
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0755',
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name]
    }
    $dst = "${dst_dir}/conf.yaml"
  } else {
    $dst = $legacy_dst
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/php_fpm.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
