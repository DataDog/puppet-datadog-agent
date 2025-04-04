# Class: datadog_agent::params
#
# This class contains the parameters for the Datadog module
#
class datadog_agent::params {
  $datadog_site                   = 'datadoghq.com'
  $dd_groups                      = undef
  $default_agent_major_version    = 7
  $agent_version                  = 'latest'
  $dogapi_version                 = 'installed'
  $gem_provider                   = 'puppetserver_gem'
  $conf_dir_purge                 = false
  $apt_default_release            = 'stable'
  $apm_default_enabled            = false
  $process_default_enabled        = false
  $process_default_scrub_args     = true
  $process_default_custom_words   = []
  $logs_enabled                   = false
  $logs_open_files_limit          = undef
  $remote_updates                 = false
  $remote_policies                = false
  $container_collect_all          = false
  $sysprobe_service_name          = 'datadog-agent-sysprobe'
  $securityagent_service_name     = 'datadog-agent-security'
  $module_metadata                = load_module_metadata($module_name)

  case $facts['os']['name'] {
    'Ubuntu','Debian','Raspbian' : {
      $rubydev_package            = 'ruby-dev'
      case $facts['os']['release']['full'] {
        '14.04': {
          # Specific ruby/rubygems package name for Ubuntu 14.04
          $ruby_package           = 'ruby'
          $rubygems_package       = 'ruby1.9.1-full'
        }
        '18.04': {
          # Specific ruby/rubygems package name for Ubuntu 18.04
          $ruby_package           = 'ruby-full'
          $rubygems_package       = 'rubygems'
        }
        default: {
          $ruby_package           = 'ruby'
          $rubygems_package       = 'rubygems'
        }
      }
      $legacy_conf_dir            = '/etc/dd-agent/conf.d'
      $conf_dir                   = '/etc/datadog-agent/conf.d'
      $dd_user                    = 'dd-agent'
      $dd_group                   = 'dd-agent'
      $service_name               = 'datadog-agent'
      $agent_log_file             = '/var/log/datadog/agent.log'
      $package_name               = 'datadog-agent'
      $permissions_directory      = '0755'
      $permissions_file           = '0644'
      $permissions_protected_file = '0600'
      $agent_binary               = '/opt/datadog-agent/bin/agent/agent'
    }
    'RedHat','CentOS','Fedora','Amazon','Scientific','OracleLinux', 'AlmaLinux', 'Rocky', 'OpenSuSE', 'SLES' : {
      $rubydev_package            = 'ruby-devel'
      $ruby_package               = 'ruby'
      $rubygems_package           = 'rubygems'
      $legacy_conf_dir            = '/etc/dd-agent/conf.d'
      $conf_dir                   = '/etc/datadog-agent/conf.d'
      $dd_user                    = 'dd-agent'
      $dd_group                   = 'dd-agent'
      $service_name               = 'datadog-agent'
      $agent_log_file             = '/var/log/datadog/agent.log'
      $package_name               = 'datadog-agent'
      $permissions_directory      = '0755'
      $permissions_file           = '0644'
      $permissions_protected_file = '0600'
      $agent_binary               = '/opt/datadog-agent/bin/agent/agent'
    }
    'Windows': {
      $legacy_conf_dir            = 'C:/ProgramData/Datadog/agent5' # Not a real path, but integrations use it to ensure => absent so it needs to be a valid path
      $conf_dir                   = 'C:/ProgramData/Datadog/conf.d'
      $dd_user                    = 'ddagentuser'
      $dd_group                   = 'S-1-5-32-544' # Administrators group, passed as SID so it works on localized Windows versions
      $service_name               = 'datadogagent'
      $agent_log_file             = 'C:/ProgramData/Datadog/logs/agent.log'
      $package_name               = 'Datadog Agent' # Must be the app's DisplayName. https://puppet.com/docs/puppet/latest/resources_package_windows.html
      $permissions_directory      = '0775' # On Windows, the Administrators group needs to maintain access,
      $permissions_file           = '0664' # otherwise puppet itself won't be able to access the file. Reported
      $permissions_protected_file = '0660' # as bug in: https://tickets.puppetlabs.com/browse/PA-2877
      $agent_binary               = 'C:/Program Files/Datadog/Datadog Agent/embedded/agent.exe'
    }
    default: { fail("Class[datadog_agent]: Unsupported operatingsystem: ${facts['os']['name']}") }
  }
}
