# Class: datadog_agent::integrations::apache
#
# This class will install the necessary configuration for the apache integration
#
# Parameters:
#   $url:
#       The URL for apache status URL handled by mod-status.
#       Defaults to http://localhost/server-status?auto
#   $username:
#   $password:
#       If your service uses basic authentication, you can optionally
#       specify a username and password that will be used in the check.
#       Optional.
#   $tags
#       Optional array of tags
#
# Sample Usage:
#
# include 'datadog_agent::integrations::apache'
#
# OR
#
# class { 'datadog_agent::integrations::apache':
#   url      => 'http://example.com/server-status?auto',
#   username => 'status',
#   password => 'hunter1',
# }
#
class datadog_agent::integrations::apache (
  String $url                               = 'http://localhost/server-status?auto',
  Optional[String] $username                = undef,
  Optional[String] $password                = undef,
  Array $tags                               = [],
  Optional[Boolean] $disable_ssl_validation = undef,
  Optional[Hash] $init_config               = undef,
  Optional[Array] $instances                = undef,
  Optional[Array] $logs                     = undef,
) inherits datadog_agent::params {
  require ::datadog_agent

  if !$instances {
    $_instances = datadog_agent::clean_empty([{
      'apache_status_url'      => $url,
      'apache_user'            => $username,
      'apache_password'        => $password,
      'tags'                   => $tags,
      'disable_ssl_validation' => $disable_ssl_validation,
    }])
  } else {
    $_instances = $instances
  }

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/apache.yaml"
  if $::datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/apache.d"
    file { $legacy_dst:
      ensure => 'absent'
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
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
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/apache.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
