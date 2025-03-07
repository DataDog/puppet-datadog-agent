# @summary
#
# This class will set-up PHP FPM monitoring
#
# See the sample php_fpm.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/php_fpm/datadog_checks/php_fpm/data/conf.yaml.example
#
# @param status_url
#        URL to fetch FPM metrics. Default: http://localhost/status
#
# @param  ping_url
#        URL to get a reliable check of the FPM pool. Default: http://localhost/ping
#
# @param  ping_reply
#        Expected response from ping_url. Default: pong
#
# @param  tags
#        Optional array of tags
#
# @param use_fastcgi
#        Use fastcgi to get stats.  Default: false
#
# @example
#
#  class { 'datadog_agent::integrations::php_fpm' :
#    status_url     => 'http://localhost/fpm_status',
#    ping_url       => 'http://localhost/fpm_ping'
#  }
#
class datadog_agent::integrations::php_fpm (
  String $status_url          = 'http://localhost/status',
  String $ping_url            = 'http://localhost/ping',
  String $ping_reply          = 'pong',
  Optional[String] $http_host = undef,
  Array $tags                 = [],
  Optional[Array] $instances  = undef,
  String $use_fastcgi         = 'false'
) inherits datadog_agent::params {
  require datadog_agent

  if !$instances {
    $_instances = [{
        'http_host'   => $http_host,
        'status_url'  => $status_url,
        'ping_url'    => $ping_url,
        'ping_reply'  => $ping_reply,
        'tags'        => $tags,
        'use_fastcgi' => $use_fastcgi,
    }]
  } else {
    $_instances = $instances
  }

  $dst_dir = "${datadog_agent::params::conf_dir}/php_fpm.d"

  file { $dst_dir:
    ensure  => directory,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_directory,
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
  $dst = "${dst_dir}/conf.yaml"

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
