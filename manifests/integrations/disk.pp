# Class: datadog_agent::integrations::disk
#
# This class will install the necessary config to hook the disk check
#
# Parameters:
#   $use_mount
#       The use_mount parameter will instruct the check to collect disk
#       and fs metrics using mount points instead of volumes.
#       (values: yes, no)
#   $all_partitions
#       The (optional) all_partitions parameter will instruct the check to
#       get metrics for all partitions. use_mount should be set to yes (to avoid
#       collecting empty device names) when using this option. (values: yes, no)
#   $tag_by_filesystem
#       The (optional) tag_by_filesystem parameter will instruct the check to
#       tag all disks with their filesystem (for ex: filesystem:nfs)
#       (values: yes, no)
#   $filesystem_exclude
#       The (optional) filesystems you wish to exclude, example: tmpfs, run,
#       dev (string or array)
#   $device_exclude
#       The (optional) devices you wish to exclude, example: /dev/sda (string or array)
#   $mountpoint_exclude
#       The (optional) mountpoints you wish to exclude, example: /tmp,
#       /mnt/somebody-elses-problem (string or array)
#   $filesystem_include
#       Specify (optional) filesystems, to only collect from them (string or array)
#   $device_include
#       Specify (optional) devices, to only collect from them (string or array)
#   $mountpoint_include
#       Specify (optional) mountpoints, to only collect from them (string or array)
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::disk' :
#      use_mount            => 'yes',
#      excluded_filesystems => '/dev/tmpfs',
#      excluded_disk_re     => '/dev/sd[e-z]*'
#  }
class datadog_agent::integrations::disk (
  Boolean $use_mount                          = false,
  $all_partitions                             = undef,
  $tag_by_filesystem                          = undef,
  Optional[Array[String]] $filesystem_exclude = undef,
  Optional[Array[String]] $device_exclude     = undef,
  Optional[Array[String]] $mountpoint_exclude = undef,
  Optional[Array[String]] $filesystem_include = undef,
  Optional[Array[String]] $device_include     = undef,
  Optional[Array[String]] $mountpoint_include = undef,
) inherits datadog_agent::params {
  require ::datadog_agent

  $computed_use_mount = $use_mount ? {
    true    => 'yes',
    default => 'no'
  }

  if $computed_use_mount !~ '^(no|yes)$' {
    fail('error during compilation')
  }

  $dst_dir = "${datadog_agent::params::conf_dir}/disk.d"

  file { $dst_dir:
    ensure  => directory,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_directory,
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
  $dst = "${dst_dir}/conf.yaml"

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/disk.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}