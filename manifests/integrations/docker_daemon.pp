# Class: datadog_agent::integrations::docker_daemon
#
# This class will install the necessary configuration for the docker integration
#
# Parameters:
#   @param group
#   @param docker_root
#   @param timeout
#   @param api_version
#   @param tls
#   @param tls_client_cert
#   @param tls_client_key
#   @param tls_cacert
#   @param tls_verify
#   @param init_retry_interval
#   @param init_retries
#   @param url
#   @param collect_events
#   @param filtered_event_types
#   @param collect_container_size
#   @param custom_cgroups
#   @param health_service_check_whitelist
#   @param collect_container_count
#   @param collect_volume_count
#   @param collect_images_stats
#   @param collect_image_size
#   @param collect_disk_stats
#   @param collect_exit_codes
#   @param exclude
#   @param include
#   @param tags
#   @param ecs_tags
#   @param performance_tags
#   @param container_tags
#   @param collect_labels_as_tags
#   @param event_attributes_as_tags
#
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::docker_daemon' :
#     url           => 'unix://var/run/docker.sock',
#   }
#
class datadog_agent::integrations::docker_daemon (
  String $group                         = 'docker',
  String $docker_root                   = '/',
  Integer $timeout                      = 10,
  String $api_version                   = 'auto',
  Boolean $tls                          = false,
  String $tls_client_cert               = '/path/to/client-cert.pem',
  String $tls_client_key                = '/path/to/client-key.pem',
  String $tls_cacert                    = '/path/to/ca.pem',
  Boolean $tls_verify                   = true,
  Integer $init_retry_interval          = 0,
  Integer $init_retries                 = 0,
  String $url                           = 'unix://var/run/docker.sock',
  Boolean $collect_events               = true,
  Array $filtered_event_types           = [],
  Boolean $collect_container_size       = false,
  Boolean $custom_cgroups               = false,
  Array $health_service_check_whitelist = [],
  Boolean $collect_container_count      = false,
  Boolean $collect_volume_count         = false,
  Boolean $collect_images_stats         = false,
  Boolean $collect_image_size           = false,
  Boolean $collect_disk_stats           = false,
  Boolean $collect_exit_codes           = false,
  Array $exclude                        = [],
  Array $include                        = [],
  Array $tags                           = [],
  Boolean $ecs_tags                     = true,
  # Possible values: "container_name", "image_name", "image_tag", "docker_image"
  Array $performance_tags               = [],
  # Possible values: "image_name", "image_tag", "docker_image"
  Array $container_tags                 = [],
  # Ex. "com.docker.compose.service", "com.docker.compose.project"
  Array $collect_labels_as_tags         = [],
  Array $event_attributes_as_tags       = [],
) inherits datadog_agent::params {
  require datadog_agent

  exec { 'dd-agent-should-be-in-docker-group':
    command => "/usr/sbin/usermod -aG ${group} ${datadog_agent::dd_user}",
    unless  => "/bin/cat /etc/group | grep '^${group}:' | grep -qw ${datadog_agent::dd_user}",
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }

  if versioncmp($datadog_agent::_agent_major_version, '5') > 0 {
    $legacy_dir = "${datadog_agent::params::conf_dir}/docker_daemon.d"

    file { $legacy_dir:
      ensure  => directory,
      owner   => $datadog_agent::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name],
    }
    $legacy_conf = "${legacy_dir}/conf.yaml"
  } else {
    $legacy_conf = "${datadog_agent::params::legacy_conf_dir}/docker.yaml"
  }

  file { $legacy_conf:
    ensure => 'absent',
  }

  if versioncmp($datadog_agent::_agent_major_version, '5') > 0 {
    $dst_dir = "${datadog_agent::params::conf_dir}/docker.d"

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
    $dst = "${datadog_agent::params::legacy_conf_dir}/docker_daemon.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_file,
    content => template('datadog_agent/agent-conf.d/docker_daemon.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
