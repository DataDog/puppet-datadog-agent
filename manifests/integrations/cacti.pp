# Class: datadog_agent::integrations::cacti
#
# This class will install the necessary configuration for the cacti integration
#
# See the sample cacti.d/conf.yaml for all available configuration options.
# https://github.com/DataDog/integrations-core/blob/master/cacti/datadog_checks/cacti/data/conf.yaml.example
# 
# Parameters:
#   $host:
#       The host cacti MySQL db is running on
#   $user
#       The cacti MySQL password
#   $password
#       The cacti MySQL sb port.
#   $path
#       The path to the cacti rrd directory e.g. /var/lib/cacti/rra/
#
class datadog_agent::integrations::cacti (
  String $mysql_host            = 'localhost',
  String $mysql_user            = 'cacti',
  Optional[Any] $mysql_password = undef,
  String $rrd_path              = '/var/lib/cacti/rra/',
) inherits datadog_agent::params {
  require datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/cacti.yaml"
  if $datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/cacti.d"
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
    content => template('datadog_agent/agent-conf.d/cacti.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
