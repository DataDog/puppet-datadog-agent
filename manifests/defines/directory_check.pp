# Class: datadog::check::directory
#
# This define contains a datadog directory check
#
# Parameters
#
#   directory
#       string, the directory to gather stats for. required
#
#   name
#       string, the name to use when tagging the metrics. defaults to the "directory"
#
#   pattern
#       string, the `fnmatch` pattern to use when reading the "directory"'s files. default "*"
#
#   recursive
#       boolean, when true the stats will recurse into directories. default False
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# datadog::check::directory { 'Media Library': 
#   directory => '/mnt/media',
#   name      => 'media',
#   pattern   => '*',
#   recursive => true,
# }
#
define datadog::check::directory (
  $directory = undef,
  $name      = $title,
  $pattern   = '*',
  $recursive = false,
) {

  if $directory == undef {
    fail("you must specify a directory path to Datadog::Check::Directory[$title]")
  }

  $directory_check_yaml_file = '/etc/dd-agent/conf.d/directory.yaml'

  if ( !defined( Concat[$directory_check_yaml_file] ) ) {
    concat { $directory_check_yaml_file:
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      notify => Service['datadog-agent'],
    }
  }

  if ( !defined( Concat::Fragment["datadog_directory_check_header"] ) ) {
    concat::fragment { "datadog_directory_check_header":
      target  => $directory_check_yaml_file,
      content => "init_config:\n\ninstances:\n",
      order   => 10,
    }
  }

  concat::fragment { "datadog_directory_check_fragment_$title":
    target  => $directory_check_yaml_file,
    content => template('datadog/directory_check.yaml.erb'),
    order   => 20,
  }

}
