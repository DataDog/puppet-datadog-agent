# @summary Enable ssh check
#
#
# @param host
#   ssh server to use for ssh check
# @param port
# @param username
# @param password
# @param sftp_check
# @param private_key_file
# @param add_missing_keys
#
#
# @example
#   class { 'datadog_agent::integrations::ssh' :
#     host             => 'localhost',
#     private_key_file => '/opt/super_secret_key',
#   }
#
class datadog_agent::integrations::ssh (
  Stdlib::Host                   $host             = $trusted['certname'],
  Stdlib::Port                   $port             = 22,
  String                         $username         = $datadog_agent::dd_user,
  Optional[String]               $password         = undef,
  Boolean                        $sftp_check       = true,
  Optional[Stdlib::Absolutepath] $private_key_file = undef,
  Boolean                        $add_missing_keys = true,
) inherits datadog_agent::params {
  require datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/ssh.yaml"
  if $datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/ssh_check.d"
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
    content => template('datadog_agent/agent-conf.d/ssh.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
