# Class: datadog_agent::integrations::docker_daemon
#
# This class will install the necessary configuration for the docker integration
#
# Parameters:
#   $url:
#     The URL for docker API
#
#   $tags:
#     optional array of tags
#
#   $group:
#     optional name of docker group to add dd-agent user too
#
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::docker_daemon' :
#     url           => 'unix://var/run/docker.sock',
#   }
#
class datadog_agent::integrations::docker_daemon(
  $group = 'docker',
  $docker_root = '/',
  $timeout = 10,
  $api_version = 'auto',
  $tls = false,
  $tls_client_cert = '/path/to/client-cert.pem',
  $tls_client_key = '/path/to/client-key.pem',
  $tls_cacert = '/path/to/ca.pem',
  $tls_verify = true,
  $init_retry_interval = 0,
  $init_retries = 0,
  $url = 'unix://var/run/docker.sock',
  $collect_events = true,
  $filtered_event_types = [],
  $collect_container_size = false,
  $custom_cgroups = false,
  $health_service_check_whitelist = [],
  $collect_container_count = false,
  $collect_volume_count = false,
  $collect_images_stats = false,
  $collect_image_size = false,
  $collect_disk_stats = false,
  $collect_exit_codes = false,
  $exclude = [],
  $include = [],
  $tags = [],
  $ecs_tags = true,
  # Possible values: "container_name", "image_name", "image_tag", "docker_image"
  $performance_tags = [],
  # Possible values: "image_name", "image_tag", "docker_image"
  $container_tags = [],
  # Ex. "com.docker.compose.service", "com.docker.compose.project"
  $collect_labels_as_tags = [],
  $event_attributes_as_tags = [],
) inherits datadog_agent::params {
  include datadog_agent

  exec { 'dd-agent-should-be-in-docker-group':
    command => "/usr/sbin/usermod -aG ${group} ${datadog_agent::params::dd_user}",
    unless  => "/bin/cat /etc/group | grep '^${group}:' | grep -qw ${datadog_agent::params::dd_user}",
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }

  if !$::datadog_agent::agent5_enable {
    $legacy_dir = "${datadog_agent::conf6_dir}/docker_daemon.d"

    file { $legacy_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => '0755',
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name]
    }
    $legacy_conf = "${legacy_dir}/conf.yaml"
  } else {
    $legacy_conf = "${datadog_agent::conf_dir}/docker.yaml"
  }

  file { $legacy_conf:
    ensure => 'absent'
  }

  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/docker.d"

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
    $dst = "${datadog_agent::conf_dir}/docker_daemon.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0644',
    content => template('datadog_agent/agent-conf.d/docker_daemon.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
