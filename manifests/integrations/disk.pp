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
#   $filesystem_blacklist
#       The (optional) filesystems you wish to exclude, example: tmpfs, run,
#       dev (string or array)
#   $device_blacklist
#       The (optional) devices you wish to exclude, example: /dev/sda (string or array)
#   $mountpoint_blacklist
#       The (optional) mountpoints you wish to exclude, example: /tmp,
#       /mnt/somebody-elses-problem (string or array)
#   $filesystem_whitelist
#       Specify (optional) filesystems, to only collect from them (string or array)
#   $device_whitelist
#       Specify (optional) devices, to only collect from them (string or array)
#   $mountpoint_whitelist
#       Specify (optional) mountpoints, to only collect from them (string or array)
#   $excluded_filesystems (DEPRECATED in agent version>6.9, use $filesystem_blacklist instead)
#       The filesystems you wish to exclude, example: tmpfs, run (string or array)
#   $excluded_disks (DEPRECATED in agent version>6.9, use $device_blacklist instead)
#       The disks you (optional)
#   $excluded_disk_re (DEPRECATED in agent version>6.9, use $device_blacklist instead)
#       Regular expression (optional) to exclude disks, eg: /dev/sde.*
#   $excluded_mountpoint_re (DEPRECATED in agent version>6.9, use $mountpoint_blacklist instead)
#       Regular expression (optional) to exclude , eg: /mnt/somebody-elses-problem.*

#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::disk' :
#      use_mount            => 'yes',
#      excluded_filesystems => '/dev/tmpfs',
#      excluded_disk_re     => '/dev/sd[e-z]*'
#  }
class datadog_agent::integrations::disk (
  String $use_mount                              = 'no',
  $all_partitions                                = undef,
  $tag_by_filesystem                             = undef,
  Optional[Array[String]] $filesystem_blacklist  = undef,
  Optional[Array[String]] $device_blacklist      = undef,
  Optional[Array[String]] $mountpoint_blacklist  = undef,
  Optional[Array[String]] $filesystem_whitelist  = undef,
  Optional[Array[String]] $device_whitelist      = undef,
  Optional[Array[String]] $mountpoint_whitelist  = undef,
  Optional[Variant[String, Array[String]]] $excluded_filesystems   = undef,  # deprecated in agent versions >6.9
  Optional[Variant[String, Array[String]]] $excluded_disks         = undef,  # deprecated in agent versions >6.9
  Optional[String] $excluded_disk_re       = undef,  # deprecated in agent versions >6.9
  Optional[String] $excluded_mountpoint_re = undef,  # deprecated in agent versions >6.9
) inherits datadog_agent::params {
  include datadog_agent

  validate_legacy('Optional[String]', 'validate_re', $all_partitions, '^(no|yes)$')

  if $use_mount !~ '^(no|yes)$' {
    fail('error during compilation')
  }

  $legacy_dst = "${datadog_agent::conf_dir}/disk.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst_dir = "${datadog_agent::conf6_dir}/disk.d"
    file { $legacy_dst:
      ensure => 'absent'
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::params::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name]
    }
    $dst = "${dst_dir}/conf.yaml"
  } else {
    $dst = $legacy_dst
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/disk.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
