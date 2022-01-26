define datadog_agent::integration (
  Array $instances                  = [],
  Optional[Hash] $init_config       = undef,
  Optional[Array] $logs             = undef,
  String $integration               = $title,
  String $conf_file                 = 'conf',
  Enum['present', 'absent'] $ensure = 'present',
){

  # We can't `require ::datadog_agent` from here since this class is used by the
  # datadog_agent class, causing a dependency cycle. If using this class
  # directly, you should define datadog_agent before datadog_agent::integration.

  if $::datadog_agent::_agent_major_version > 5 {
    $dst_dir = "${datadog_agent::params::conf_dir}/${integration}.d"
    $dst = "${dst_dir}/${$conf_file}.yaml"
    if (! defined(File[$dst_dir])) {
      file { $dst_dir:
        ensure => directory,
        owner  => $datadog_agent::dd_user,
        group  => $datadog_agent::dd_group,
        mode   => $datadog_agent::params::permissions_directory,
        before => File[$dst]
      }
    }
  } else {
    $dst = "${datadog_agent::params::legacy_conf_dir}/${integration}.yaml"
  }

  $file_ensure = $ensure ? { default => file, 'absent' => absent }

  file { $dst:
    ensure  => $file_ensure,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::dd_group,
    mode    => $datadog_agent::params::permissions_file,
    content => to_instances_yaml($init_config, $instances, $logs),
    notify  => Service[$datadog_agent::params::service_name]
  }

}
