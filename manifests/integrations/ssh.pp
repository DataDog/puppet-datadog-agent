# Class: datadog_agent::integrations::ssh
#
# This class will enable ssh check
#
# See the sample ssh_check.d/conf.yaml for all available configuration options
# https://github.com/DataDog/integrations-core/blob/master/ssh_check/datadog_checks/ssh_check/data/conf.yaml.example
#
# Parameters:
#   $host:
#        ssh server to use for ssh check
#
#   $port
#
#   $username
#
#   $password
#
#   $sftp_check
#
#   $private_key_file
#
#   $add_missing_keys
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::ssh' :
#    host             => 'localhost',
#    private_key_file => '/opt/super_secret_key',
#  }
#
class datadog_agent::integrations::ssh (
  String $host                       = $trusted['certname'],
  Integer $port                      = 22,
  String $username                   = $datadog_agent::dd_user,
  Optional[Any] $password            = undef,
  Boolean $sftp_check                = true,
  Optional[String] $private_key_file = undef,
  Boolean $add_missing_keys          = true,
) inherits datadog_agent::params {
  require datadog_agent

  $dst_dir = "${datadog_agent::params::conf_dir}/ssh_check.d"

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
    content => template('datadog_agent/agent-conf.d/ssh.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
