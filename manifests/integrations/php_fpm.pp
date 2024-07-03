# @summary Set-up PHP FPM monitoring
#
#
# @param status_url
#   URL to fetch FPM metrics. Default: http://localhost/status
# @param ping_url
#   URL to get a reliable check of the FPM pool. Default: http://localhost/ping
# @param ping_reply
#   Expected response from ping_url. Default: pong
# @param http_host
# @param tags
#   Optional array of tags
# @param instances
# @param use_fastcgi
#   Use fastcgi to get stats.  Default: false
#
#
# @example
#   class { 'datadog_agent::integrations::php_fpm' :
#     status_url     => 'http://localhost/fpm_status',
#     ping_url       => 'http://localhost/fpm_ping'
#   }
#
class datadog_agent::integrations::php_fpm (
  Stdlib::HTTPUrl        $status_url  = 'http://localhost/status',
  Stdlib::HTTPUrl        $ping_url    = 'http://localhost/ping',
  String                 $ping_reply  = 'pong',
  Optional[Stdlib::Host] $http_host   = undef,
  Array                  $tags        = [],
  Optional[Hash]         $instances   = undef,
  Enum['true', 'false']  $use_fastcgi = 'false'
) inherits datadog_agent::params {
  require datadog_agent

  if !$instances {
    $_instances = [{
        'http_host' => $http_host,
        'status_url' => $status_url,
        'ping_url' => $ping_url,
        'ping_reply' => $ping_reply,
        'tags' => $tags,
        'use_fastcgi' => $use_fastcgi,
    }]
  } else {
    $_instances = $instances
  }

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/php_fpm.yaml"
  if $datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/php_fpm.d"
    file { $legacy_dst:
      ensure => 'absent',
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name],
    }
    $dst = "${dst_dir}/conf.yaml"
  } else {
    $dst = $legacy_dst
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/php_fpm.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
