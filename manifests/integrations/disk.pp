# Class: datadog_agent::integrations::disk
#
# This class will install the necessary config to hook the disk check
#
# Parameters:
#   @param use_mount
#       The use_mount parameter will instruct the check to collect disk
#       and fs metrics using mount points instead of volumes.
#       (values: yes, no)
#   @param all_partitions
#       The (optional) all_partitions parameter will instruct the check to
#       get metrics for all partitions. use_mount should be set to yes (to avoid
#       collecting empty device names) when using this option. (values: yes, no)
#   @param tag_by_filesystem
#       The (optional) tag_by_filesystem parameter will instruct the check to
#       tag all disks with their filesystem (for ex: filesystem:nfs)
#       (values: yes, no)
#   @param filesystem_exclude
#       The (optional) filesystems you wish to exclude, example: tmpfs, run,
#       dev (string or array)
#   @param device_exclude
#       The (optional) devices you wish to exclude, example: /dev/sda (string or array)
#   @param mountpoint_exclude
#       The (optional) mountpoints you wish to exclude, example: /tmp,
#       /mnt/somebody-elses-problem (string or array)
#   @param filesystem_include
#       Specify (optional) filesystems, to only collect from them (string or array)
#   @param device_include
#       Specify (optional) devices, to only collect from them (string or array)
#   @param mountpoint_include
#       Specify (optional) mountpoints, to only collect from them (string or array)
#   @param filesystem_blacklist (DEPRECATED in agent version>7.24, use $filesystem_exclude instead)
#       The (optional) filesystems you wish to exclude, example: tmpfs, run,
#       dev (string or array)
#   @param device_blacklist (DEPRECATED in agent version>7.24, use $device_exclude instead)
#       The (optional) devices you wish to exclude, example: /dev/sda (string or array)
#   @param mountpoint_blacklist (DEPRECATED in agent version>7.24, use $mountpoint_exclude instead)
#       The (optional) mountpoints you wish to exclude, example: /tmp,
#       /mnt/somebody-elses-problem (string or array)
#   @param filesystem_whitelist  DEPRECATED in agent version>7.24, use $device_include instead)
#       Specify (optional) filesystems, to only collect from them (string or array)
#   @param device_whitelist (DEPRECATED in agent version>7.24, use $device_include instead)
#       Specify (optional) devices, to only collect from them (string or array)
#   @param mountpoint_whitelist (DEPRECATED in agent version>7.24, use $mountpoint_include instead)
#       Specify (optional) mountpoints, to only collect from them (string or array)
#   @param excluded_filesystems (DEPRECATED in agent version>6.9, use $filesystem_exclude instead)
#       The filesystems you wish to exclude, example: tmpfs, run (string or array)
#   @param excluded_disks (DEPRECATED in agent version>6.9, use $device_exclude instead)
#       The disks you (optional)
#   @param excluded_disk_re (DEPRECATED in agent version>6.9, use $device_exclude instead)
#       Regular expression (optional) to exclude disks, eg: /dev/sde.*
#   @param excluded_mountpoint_re (DEPRECATED in agent version>6.9, use $mountpoint_exclude instead)
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
  Optional[String] $all_partitions               = undef,
  Optional[String] $tag_by_filesystem            = undef,
  Optional[Array[String]] $filesystem_exclude    = undef,
  Optional[Array[String]] $device_exclude        = undef,
  Optional[Array[String]] $mountpoint_exclude    = undef,
  Optional[Array[String]] $filesystem_include    = undef,
  Optional[Array[String]] $device_include        = undef,
  Optional[Array[String]] $mountpoint_include    = undef,
  Optional[Array[String]] $filesystem_blacklist  = undef, # deprecated in agent version >7.24
  Optional[Array[String]] $device_blacklist      = undef, # deprecated in agent version >7.24
  Optional[Array[String]] $mountpoint_blacklist  = undef, # deprecated in agent version >7.24
  Optional[Array[String]] $filesystem_whitelist  = undef, # deprecated in agent version >7.24
  Optional[Array[String]] $device_whitelist      = undef, # deprecated in agent version >7.24
  Optional[Array[String]] $mountpoint_whitelist  = undef, # deprecated in agent version >7.24
  Optional[Variant[String, Array[String]]] $excluded_filesystems   = undef,  # deprecated in agent versions >6.9
  Optional[Variant[String, Array[String]]] $excluded_disks         = undef,  # deprecated in agent versions >6.9
  Optional[String] $excluded_disk_re       = undef,  # deprecated in agent versions >6.9
  Optional[String] $excluded_mountpoint_re = undef,  # deprecated in agent versions >6.9
) inherits datadog_agent::params {
  require datadog_agent

  validate_legacy('Optional[String]', 'validate_re', $all_partitions, '^(no|yes)$')

  if $use_mount !~ '^(no|yes)$' {
    fail('error during compilation')
  }

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/disk.yaml"
  if versioncmp($datadog_agent::_agent_major_version, '5') > 0 {
    $dst_dir = "${datadog_agent::params::conf_dir}/disk.d"
    file { $legacy_dst:
      ensure => 'absent',
    }

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
    $dst = $legacy_dst
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/disk.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
