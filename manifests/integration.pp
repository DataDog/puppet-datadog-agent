define datadog_agent::integration (
  $instances,
  $integration = $title,
){

  include datadog_agent

  validate_array($instances)
  validate_string($integration)

  file { "${datadog_agent::conf_dir}/${integration}.yaml":
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::dd_group,
    mode    => '0600',
    content => to_instances_yaml($instances),
    notify  => Service[$datadog_agent::service_name]
  }

}
