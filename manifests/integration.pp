define datadog_agent::integration (
  $instances,
  $init_config = undef,
  $integration = $title,
){

  include datadog_agent

  if !$::datadog_agent::agent5_enable {
    $dst = "${datadog_agent::conf6_dir}/${integration}.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/${integration}.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::dd_group,
    mode    => '0600',
    content => to_instances_yaml($init_config, $instances),
    notify  => Service[$datadog_agent::service_name]
  }

}
