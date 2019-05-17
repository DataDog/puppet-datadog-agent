# Class: datadog_agent::integrations::cacti
#
# This class will install the necessary configuration for the cacti integration
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
class datadog_agent::integrations::cacti(
  $mysql_host = 'localhost',
  $mysql_user = 'cacti',
  $mysql_password = undef,
  $rrd_path = '/var/lib/cacti/rra/',
) inherits datadog_agent::params {
  include datadog_agent

  $legacy_dst = "${datadog_agent::conf_dir}/cacti.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/cacti.d"
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
    content => template('datadog_agent/agent-conf.d/cacti.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
