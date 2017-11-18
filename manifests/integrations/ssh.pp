# Class: datadog_agent::integrations::ssh
#
# This class will enable ssh check
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

class datadog_agent::integrations::ssh(
  $host              = $::fqdn,
  $port              = 22,
  $username          = $datadog_agent::params::dd_user,
  $password          = undef,
  $sftp_check        = true,
  $private_key_file  = undef,
  $add_missing_keys  = true,
) inherits datadog_agent::params {
  include ::datadog_agent

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/ssh.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/ssh.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/ssh.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
