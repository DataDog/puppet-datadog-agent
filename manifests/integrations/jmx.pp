# Class: datadog_agent::integrations::jmx
#
# This class will install the necessary configuration for the jmx integration
#
# Parameters:
#   @param init_config
#       Hash of inital configuration, consisting of the following keys:
#
#   @param instances
#       Array of instance hashes, consisting of the following keys:
#
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::jmx':
#    init_config        => {
#      custom_jar_paths => ['/path/to/custom.jar']
#    },
#    instances  => [{
#      host     => 'localhost',
#      port     => 7199,
#      user     => 'username',
#      password => 'password',
#      jmx_url  => 'service:jmx:rmi:///jndi/rmi://myhost.host:9999/custompath'
#    }],
#  }
#
class datadog_agent::integrations::jmx (
  Hash $init_config = {},
  Array $instances  = [],
) inherits datadog_agent::params {
  require datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/jmx.yaml"
  if versioncmp($datadog_agent::_agent_major_version, '5') > 0 {
    $dst_dir = "${datadog_agent::params::conf_dir}/jmx.d"
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
    content => template('datadog_agent/agent-conf.d/jmx.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
