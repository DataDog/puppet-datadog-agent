define datadog_agent::integration (
  $instances,
  $init_config = undef,
  $integration = $title,
){

  include datadog_agent

  validate_array($instances)
  if $init_config != undef {
    validate_hash($init_config)
  }
  validate_string($integration)

  if $::datadog_agent::agent6_enable {
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
