# Class: datadog_agent::integrations::disk
#
# This class will install the necessary config to hook the disk check
#
# Parameters:
#   $use_mount
#       The use_mount parameter will instruct the check to collect disk
#       and fs metrics using mount points instead of volumes.
#       values: yes, no (Boolean, default: no)
#   $excluded_filesystems
#       The filesystems you wish to exclude, example: tmpfs, run (string or array)
#   $excluded_disks
#       The disks you (optional) wish to exclude, example: /dev/sda (string or array)
#   $excluded_disk_re
#       Regular expression (optional) to exclude disks, eg: /dev/sde.*
#   $excluded_mountpoint_re
#       Regular expression (optional) to exclude mountpoints, eg: /mnt/somebody-elses-problem.*
#   $all_partitions
#       The (optional) all_partitions parameter will instruct the check to
#       get metrics for all partitions. use_mount should be set to yes (to avoid
#       collecting empty device names) when using this option.
#   $tag_by_filesystem
#       The (optional) tag_by_filesystem parameter will instruct the check to
#       tag all disks with their filesystem (for ex: filesystem:nfs)
#       valuse: yes, no (Boolean, default: no)
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::disk' :
#      use_mount            => 'yes',
#      excluded_filesystems => '/dev/tmpfs',
#      excluded_disk_re     => '/dev/sd[e-z]*'
#  }
class datadog_agent::integrations::disk (
  $use_mount              = 'no',
  $excluded_filesystems   = undef,
  $excluded_disks         = undef,
  $excluded_disk_re       = undef,
  $excluded_mountpoint_re = undef,
  $all_partitions         = undef,
  $tag_by_filesystem      = undef
) inherits datadog_agent::params {
  include datadog_agent

  validate_re($use_mount, '^(no|yes)$', "use_mount should be either 'yes' or 'no'")
  if $all_partitions {
    validate_re($all_partitions, '^(no|yes)$', "all_partitions should be either 'yes' or 'no'")
  }

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/disk.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/disk.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/disk.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
