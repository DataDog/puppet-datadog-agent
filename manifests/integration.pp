define datadog_agent::integration (
  $instances,
  $init_config = undef,
  $integration = $title,
){

  include datadog_agent

  validate_legacy(Array, 'validate_array', $instances)
  validate_legacy(Optional[Hash], 'validate_hash', $init_config)
  validate_legacy(String, 'validate_string', $integration)

  if !$::datadog_agent::agent5_enable {
    $dst = "${datadog_agent::conf6_dir}/${integration}.d/conf.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/${integration}.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::dd_group,
    mode    => '0644',
    content => to_instances_yaml($init_config, $instances),
    notify  => Service[$datadog_agent::service_name]
  }

}
