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

  $legacy_dst = "${datadog_agent::conf_dir}/ssh.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/ssh_check.d"
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
    content => template('datadog_agent/agent-conf.d/ssh.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
