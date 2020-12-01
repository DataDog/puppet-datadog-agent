define datadog_agent::integration (
  Array $instances                  = [],
  Optional[Hash] $init_config       = undef,
  Optional[Array] $logs             = undef,
  String $integration               = $title,
  Enum['present', 'absent'] $ensure = 'present',
){

  include datadog_agent

  if $::datadog_agent::_agent_major_version > 5 {
    $dst = "${datadog_agent::params::conf_dir}/${integration}.d/conf.yaml"
    file { "${datadog_agent::params::conf_dir}/${integration}.d":
      ensure => directory,
      owner  => $datadog_agent::dd_user,
      group  => $datadog_agent::dd_group,
      mode   => $datadog_agent::params::permissions_directory,
      before => File[$dst]
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
