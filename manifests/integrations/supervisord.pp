# Class: datadog_agent::integrations::supervisord
#
# This class will install the necessary configuration for the supervisord integration
#
# Parameters:
#   @param instances
#
#
# Sample Usage:
#
# class { 'datadog_agent::integrations::supervisord':
#   instances => [
#     {
#       servername => 'server0',
#       socket     => 'unix:///var/run//supervisor.sock',
#     },
#     {
#       servername => 'server1',
#       hostname   => 'localhost',
#       port       => '9001',
#       proc_names => ['java', 'apache2'],
#     },
#   ],
# }
#
#
#
class datadog_agent::integrations::supervisord (
  Array $instances = [{ 'servername' => 'server0', 'hostname' => 'localhost', 'port' => '9001' }],
) inherits datadog_agent::params {
  require datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/supervisord.yaml"
  if versioncmp($datadog_agent::_agent_major_version, '5') > 0 {
    $dst_dir = "${datadog_agent::params::conf_dir}/supervisord.d"
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
    content => template('datadog_agent/agent-conf.d/supervisord.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
