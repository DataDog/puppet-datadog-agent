define datadog_agent::pip_install (
  Enum['present', 'absent'] $ensure       = 'present',
  String                    $package_name = $title,
  Optional[String]          $version      = undef,
  Optional[String]          $index_url    = undef,
) {
  include datadog_agent

  # Currently this package only supports linux but should allow for easy scaling to support other operating systems
  $python_bin = '/opt/datadog-agent/embedded/bin/python'
  # Check if this package should be installed from a specific Python Package Index
  if $index_url == undef {
    $index_url_flag = ''
  } else {
    $index_url_flag = "--index-url=${index_url}"
  }

  if $version == undef {
    $package_and_version = "${package_name}"
  } else {
    $package_and_version = "${package_name}==${version}"
  }
  $install_command = "${python_bin} -m pip install ${package_and_version} ${index_url_flag}"
  $uninstall_command = "${python_bin} -m pip uninstall ${package_and_version} --yes"
  $freeze_command = "${python_bin} -m pip freeze | grep ${package_and_version}"

  if $ensure == 'present' {
    exec {"install ${package_name}":
      command  => $install_command,
      user     => $::datadog_agent::dd_user,
      unless   => $freeze_command,
      require  => Package[$::datadog_agent::params::package_name],
      notify   => Service[$::datadog_agent::params::service_name],
    }
  } else {
    exec {"remove ${package_name}":
      command  => $uninstall_command,
      user     => $::datadog_agent::dd_user,
      onlyif   => $freeze_command,
      require  => Package[$::datadog_agent::params::package_name],
      notify   => Service[$::datadog_agent::params::service_name],
    }
  }
}
