# Class: datadog_agent::integrations::directory
#
# This class will install the necessary config to hook the directory in the agent
#
# Parameters:
#   @param directory
#       (Required) - string, the directory path to monitor
#       This will be included as a tag: name:<name>.
#
#   @param dirtagname
#       (Optional) - string, the name of the key for the tag used for the directory, the value will be the value of "name" (see above). The resulting tag will be "<dirtagname>:<name>". defaults to "name"
#
#   @param filetagname
#       (Optional) - string, the name of the key for the tag used for each file, the value will be the filename. The resulting tag will be "<filetagname>:<filename>". defaults to "filename"
#
#   @param filegauges
#       (Optional) - boolean, when true stats will be an individual gauge per file (max. 20 files!) and not a histogram of the whole directory. default False
#
#   @param pattern
#       (Optional) - string, the `fnmatch` pattern to use when reading the "directory"'s files. The pattern will be matched against the files' absolute paths and relative paths in "directory". default "*"
#
#   @param recursive
#       (Optional) - boolean, when true the stats will recurse into directories. default False
#
#   @param countonly
#       (Optional) - boolean, when true the stats will only count the number of files matching the pattern. Useful for very large directories.
#
#   @param nametag
#
#   @param instances
#
#
# Sample Usage:
#
# Add a class for each check instance:
#
# class { 'datadog_agent::integrations::directory':
#   directory => '/opt/ftp_data',
#   recursive => true,
#   countonly => true,
# }
#
# Add multiple instances in one class declaration:
#
# class { 'datadog_agent::integrations::directory':
#   instances => [{
#     'directory' => '/opt/ftp_data',
#     'recursive' => true,
#     'countonly' => true,
#     },
#     'directory' => '/opt/ftp_data-staging',
#     'recursive' => true,
#     'countonly' => true,
#     },
#   ]
# }

class datadog_agent::integrations::directory (
  Optional[String] $directory   = undef,
  Boolean $filegauges           = false,
  Boolean $recursive            = true,
  Boolean $countonly            = false,
  Optional[String] $nametag     = undef,
  Optional[String] $dirtagname  = undef,
  Optional[String] $filetagname = undef,
  Optional[String] $pattern     = undef,
  Optional[Array] $instances    = undef,
) inherits datadog_agent::params {
  require datadog_agent

  if !$instances and $directory == '' {
    fail('bad directory argument and no instances hash provided')
  }

  if !$instances and $directory {
    $_instances = [{
        'directory'   => $directory,
        'filegauges'  => $filegauges,
        'recursive'  => $recursive,
        'countonly' => $countonly,
        'name' => $nametag,
        'dirtagname' => $dirtagname,
        'filetagname' => $filetagname,
        'pattern' => $pattern,
    }]
  } elsif !$instances {
    $_instances = []
  } else {
    $_instances = $instances
  }

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/directory.yaml"
  if versioncmp($datadog_agent::_agent_major_version, '5') > 0 {
    $dst_dir = "${datadog_agent::params::conf_dir}/directory.d"
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
    content => template('datadog_agent/agent-conf.d/directory.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
