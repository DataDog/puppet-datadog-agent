# Class: datadog_agent
#
# This class contains the agent installation mechanism for the Datadog module
#
# Parameters:
#   @param dd_url
#       The host of the Datadog intake server to send agent data to.
#       Defaults to https://app.datadoghq.com.
#   @param datadog_site
#       The site of the Datadog intake to send Agent data to. Defaults to 'datadoghq.com',
#       can be set to 'datadoghq.eu' to send data to the EU site or 'us3.datadoghq.com'.
#       This option is only available with agent version >= 6.6.0.
#   @param host
#       Force the hostname to whatever you want. (default: auto-detected)
#   @param api_key
#       Your DataDog API Key. Please replace with your key value.
#   @param agent_flavor
#       Linux-only. The Agent flavor to install, eg: "datadog-agent" or "datadog-iot-agent".
#   @param collect_ec2_tags
#       Collect AWS EC2 custom tags as agent tags.
#       Boolean. Default: false
#   @param collect_gce_tags
#       Collect Google Cloud Engine metadata as agent tags.
#       Boolean. Default: false
#   @param collect_instance_metadata
#       The Agent will try to collect instance metadata for EC2 and GCE instances.
#       Boolean. Default: true
#   @param tags
#       Optional array of tags.
#   @param hiera_tags
#       Boolean to grab tags from hiera to allow merging
#   @param facts_to_tags
#       Optional array of facts' names that you can use to define tags following the scheme: "fact_name:fact_value".
#       See also trusted_facts_to_tags.
#       Note: this is not for Puppet Report Tags.  See report_fact_tags
#   @param trusted_facts_to_tags
#       Optional array of trusted facts' names that you can use to define tags following
#       the scheme: "fact_name:fact_value".
#       Note: this is not for Puppet Report Tags.  See report_trusted_fact_tags
#   @param puppet_run_reports
#       Will send results from your puppet agent runs back to the datadog service.
#   @param reports_url
#       The URL to use when sending puppet run reports. Default: https://api.${datadog_site}
#   @param manage_dogapi_gem
#       When reports are enabled, ensure the dogapi gem (required) is installed.
#   @param puppetmaster_user
#       Will chown the api key used by the report processor to this user.
#       Defaults to the user the puppetmaster is configured to run as.
#   @param non_local_traffic
#       Enable you to use the agent as a proxy. Defaults to false.
#       See https://github.com/DataDog/dd-agent/wiki/Proxy-Configuration
#   @param log_level
#       Set value of 'log_level' variable. Default is 'info' as in dd-agent.
#       Valid values here are: critical, debug, error, fatal, info, warn and warning.
#   @param hostname_extraction_regex
#       Completely optional.
#       Instead of reporting the puppet nodename, use this regex to extract the named
#       'hostname' captured group to report the run in Datadog.
#       ex.: '^(?<hostname>.*\.datadoghq\.com)(\.i-\w{8}\..*)?$'
#   @param hostname_fqdn
#       Make the agent use "hostname -f" on unix-based systems as a last resort
#       way of determining the hostname instead of Golang "os.Hostname()"
#       This will be enabled by default in version 6.6
#       More information at  https://dtdg.co/flag-hostname-fqdn
#       Optional: Valid values here are: true or false.
#   @param log_to_syslog
#       Set value of 'log_to_syslog' variable. Default is true -> yes as in dd-agent.
#       Valid values here are: true or false.
#   @param report_fact_tags
#       Sets tags for report events sent to Datadog from specified facts
#   @param report_trusted_fact_tags
#       Sets tags for report events sent to Datadog from specified trusted facts
#   @param statsd_forward_host
#       Set the value of the statsd_forward_host varable. Used to forward all
#       statsd metrics to another host.
#   @param manage_repo
#       Deprecated. Only works for RPM. Install datadog-agent manually and then set
#       manage_install=false to achieve the same behaviour as setting this to false.
#   @param manage_install
#       Boolean to indicate whether this module should attempt to install the
#       Agent, or assume it will be installed by other means. Default true.
#   @param graphite_listen_port
#       Set graphite listener port
#   @param extra_template
#       Optional, append this extra template file at the end of
#       the default datadog.conf template
#   @param skip_apt_key_trusting
#       Skip trusting the apt key. Default is false. Useful if you have a
#       separate way of adding keys.
#   @param skip_ssl_validation
#       Skip SSL validation.
#   @param use_curl_http_client
#       Uses the curl HTTP client for the forwarder
#   @param recent_point_threshold
#       Sets the threshold for accepting points.
#   String. Default: empty (30 second intervals)
#   @param listen_port
#       Change the port that the agent listens on
#       String. Default: empty (port 17123 in dd-agent)
#   @param additional_checksd
#       Additional directory to look for datadog checks in
#       String. Default: undef
#   @param bind_host
#       The loopback address the forwarder and Dogstatsd will bind.
#       String. Default: empty
#   @param use_pup
#       Enables the local pup dashboard
#       Boolean. Default: false
#   @param pup_port
#       Specifies the port to be used by pup. Must have use_pup set
#       String. Default: empty
#   @param pup_interface
#       Specifies which interface pup will use. Must have use_pup set
#       String. Default: empty
#   @param pup_url
#       Specifies the URL used to access pup. Must have use_pup set
#       String. Default: empty
#   @param use_dogstatsd
#       Enables the dogstatsd server
#       Boolean. Default: true
#   @param dogstatsd_socket
#       Specifies the socket file to be used by dogstatsd. Must have use_dogstatsd set
#       String. Default: empty
#   @param dogstatsd_port
#       Specifies the port to be used by dogstatsd. Must have use_dogstatsd set
#       String. Default: 8125
#   @param dogstatsd_target
#       Change the target to be used by dogstatsd. Must have use_dogstatsd set
#       set
#       String. Default: empty
#   @param dogstatsd_interval
#       Change the dogstatsd flush period. Must have use_dogstatsd set
#       String. Default: empty ( 10 second interval)
#   @param dogstatsd_normalize
#       Enables 1 second nomralization. Must have use_dogstatsd set
#       Boolean. Default: true
#   @param statsd_forward_port
#       Specifies port for $statsd_forward_host. Must have use_dogstatsd set String.
#       Used to forward all statsd metrics to another host.
#       Default: empty
#   @param device_blacklist_re
#       Specifies pattern for device blacklisting.
#       String. Default: empty
#   @param ganglia_host
#       Specifies host where gmetad is running
#       String. Default: empty
#   @param ganglia_port
#       Specifies port  for $ganglia_host
#       String. Default: empty
#   @param dogstreams
#       Specifies port for list of logstreams/modules to be used.
#       String. Default: empty
#   @param custom_emitters
#       Specifies a comma seperated list of non standard emitters to be used
#       String. Default: empty
#   @param agent_log_file
#       Specifies the log file location (Agent 6 and 7 only).
#       String. Default: empty
#   @param collector_log_file
#       Specifies the log file location for the collector system
#       String. Default: empty
#   @param forwarder_log_file
#       Specifies the log file location for the forwarder system
#       String. Default: empty
#   @param pup_log_file
#       Specifies the log file location for the pup system
#       String. Default: empty
#   @param apm_enabled
#       Boolean to enable or disable the trace agent
#       Boolean. Default: false
#   @param apm_env
#       String defining the environment for the APM traces
#       String. Default: non
#   @param apm_non_local_traffic
#       Accept non local apm traffic. Defaults to false.
#       Boolean. Default: false
#   @param apm_analyzed_spans
#       Hash defining the APM spans to analyze and their rates.
#       Optional Hash. Default: undef.
#   @param apm_obfuscation
#       Hash defining obfuscation rules for sensitive data. (Agent 6 and 7 only).
#       Optional Hash. Default: undef
#   @param process_enabled
#       String to enable the process/container agent
#       Boolean. Default: false
#   @param scrub_args
#       Boolean to enable or disable the process cmdline scrubbing by the process-agent
#       Boolean. Default: true
#   @param custom_sensitive_words
#       Array to add more words to be used on the process cdmline scrubbing by the process-agent
#       Array. Default: []
#   @param logs_enabled
#       Boolean to enable or disable the logs agent
#       Boolean. Default: false
#   @param logs_open_files_limit
#       Integer set the max number of open files for the logs agent
#       Integer. Default: 100 if undef
#   @param container_collect_all
#       Boolean to enable logs collection for all containers
#       Boolean. Default: false
#   @param cmd_port
#       The port on which the IPC api listens
#       Integer. Default: 5001
#   @param agent_repo_uri
#       Where to download the agent from. When undef, it uses the following defaults:
#       APT: https://apt.datadoghq.com/
#       RPM: https://yum.datadoghq.com/stable/7/x86_64/ (with matching agent version and architecture)
#       Windows: https://https://s3.amazonaws.com/ddagent-windows-stable/
#       String. Default: undef
#   @param rpm_repo_gpgcheck
#       Whether or not to perform repodata signature check for RPM repositories.
#       Applies to Red Hat and SUSE platforms. When set to `undef`, this is activated
#       for all Agent versions other than 5 when `agent_repo_uri` is also undefinded.
#       The `undef` value also translates to `false` on RHEL/CentOS 8.1 because
#       of a bug in libdnf: https://bugzilla.redhat.com/show_bug.cgi?id=1792506
#       Boolean. Default: undef
#   @param apt_release
#       The distribution channel to be used for the APT repo. Eg: 'stable' or 'beta'.
#       String. Default: stable
#   @param windows_npm_install
#       (Windows only) Boolean to install the Windows NPM driver.
#       To use NPM features it is necessary to enable install through this flag, as well as
#       configuring NPM through the datadog::system_probe class.
#       Boolean. Default: false
#   @param windows_ddagentuser_name
#       (Windows only) The name of Windows user to use, in the format `<domain>\<user>`.
#
#   @param windows_ddagentuser_password
#       (Windows only) The password used to register the service`.
#
#   @param integrations
#
#   @param hiera_integrations
#
#   @param puppet_gem_provider
#
#   @param service_ensure
#
#   @param service_enable
#
#   @param statsd_histogram_percentiles
#
#   @param proxy_host
#
#   @param proxy_port
#
#   @param proxy_user
#
#   @param proxy_password
#
#   @param dogstatsd_log_file
#
#   @param syslog_host
#
#   @param syslog_port
#
#   @param service_discovery_backend
#
#   @param sd_config_backend
#
#   @param sd_backend_host
#
#   @param sd_backend_port
#
#   @param sd_template_dir
#
#   @param sd_jmx_enable
#
#   @param consul_token
#
#   @param agent_major_version
#
#   @param conf_dir
#
#   @param conf_dir_purge
#
#   @param dd_group
#
#   @param dd_groups
#
#   @param agent_extra_options
#
#   @param use_apt_backup_keyserver
#
#   @param apt_backup_keyserver
#
#   @param apt_keyserver
#
#   @param win_msi_location
#
#   @param win_ensure
#
#   @param service_provider
#
#   @param agent_version
#
# Sample Usage:
#
# include datadog_agent
#
# OR
#
# class { 'datadog_agent':
#     api_key   => 'your key',
#     tags      => ['env:production', 'linux'],
#     puppet_run_reports  => false,
#     puppetmaster_user   => puppet,
# }
#
#
class datadog_agent (
  Optional[String] $dd_url = undef,
  String $datadog_site = $datadog_agent::params::datadog_site,
  Optional[String] $host = undef,
  String $api_key = 'your_API_key',
  Enum['datadog-agent', 'Datadog Agent', 'datadog-iot-agent'] $agent_flavor = $datadog_agent::params::package_name,
  Boolean $collect_ec2_tags = false,
  Boolean $collect_gce_tags = false,
  Boolean $collect_instance_metadata = true,
  Array $tags = [],
  Hash $integrations = {},
  Boolean $hiera_integrations = false,
  Boolean $hiera_tags = false,
  Array $facts_to_tags = [],
  Array $trusted_facts_to_tags = [],
  Boolean $puppet_run_reports = false,
  String $reports_url = "https://api.${datadog_site}",
  String $puppetmaster_user = $settings::user,
  String $puppet_gem_provider = $datadog_agent::params::gem_provider,
  Boolean $non_local_traffic = false,
  Array $dogstreams = [],
  String $log_level = 'info',
  Boolean $log_to_syslog = true,
  String $service_ensure = 'running',
  Boolean $service_enable = true,
  Boolean $manage_repo = true,
  Boolean $manage_dogapi_gem = true,
  Boolean $manage_install = true,
  Optional[String] $hostname_extraction_regex = undef,
  Boolean $hostname_fqdn = false,
  Variant[Stdlib::Port, Pattern[/^\d*$/]] $dogstatsd_port = 8125,
  Optional[String] $dogstatsd_socket = undef,
  Array $report_fact_tags = [],
  Array $report_trusted_fact_tags = [],
  Optional[String] $statsd_forward_host = undef,
  Optional[Variant[Stdlib::Port, Pattern[/^\d*$/]]] $statsd_forward_port = undef,
  String $statsd_histogram_percentiles = '0.95',
  Optional[String] $proxy_host = undef,
  Optional[Variant[Integer, Pattern[/^\d*$/]]] $proxy_port = undef,
  Optional[String] $proxy_user = undef,
  Optional[String] $proxy_password = undef,
  Optional[Variant[Stdlib::Port, Pattern[/^\d*$/]]] $graphite_listen_port = undef,
  Optional[String] $extra_template = undef,
  Optional[String] $ganglia_host = undef,
  Variant[Stdlib::Port, Pattern[/^\d*$/]] $ganglia_port = 8651,
  Boolean $skip_ssl_validation = false,
  Boolean $skip_apt_key_trusting = false,
  Boolean $use_curl_http_client = false,
  Optional[String] $recent_point_threshold = undef,
  Optional[Variant[Stdlib::Port, Pattern[/^\d*$/]]] $listen_port = undef,
  Optional[String] $additional_checksd = undef,
  Optional[String] $bind_host = undef,
  Boolean $use_pup = false,
  Optional[Variant[Stdlib::Port, Pattern[/^\d*$/]]] $pup_port = undef,
  Optional[String] $pup_interface = undef,
  Optional[String] $pup_url = undef,
  Boolean $use_dogstatsd = true,
  Optional[String] $dogstatsd_target = undef,
  Optional[String] $dogstatsd_interval = undef,
  Boolean $dogstatsd_normalize = true,
  Optional[String] $device_blacklist_re = undef,
  Optional[String] $custom_emitters = undef,
  String $agent_log_file = $datadog_agent::params::agent_log_file,
  Optional[String] $collector_log_file = undef,
  Optional[String] $forwarder_log_file = undef,
  Optional[String] $dogstatsd_log_file = undef,
  Optional[String] $pup_log_file = undef,
  Optional[String] $syslog_host  = undef,
  Optional[Variant[Stdlib::Port, Pattern[/^\d*$/]]] $syslog_port  = undef,
  Optional[String] $service_discovery_backend = undef,
  Optional[String] $sd_config_backend = undef,
  Optional[String] $sd_backend_host = undef,
  Integer $sd_backend_port = 0,
  Optional[String] $sd_template_dir = undef,
  Boolean $sd_jmx_enable = false,
  Optional[String] $consul_token = undef,
  Integer $cmd_port = 5001,
  Optional[Variant[Integer, String]] $agent_major_version = undef,
  Optional[String] $conf_dir = undef,
  Boolean $conf_dir_purge = $datadog_agent::params::conf_dir_purge,
  String $dd_group = $datadog_agent::params::dd_group,
  Optional[String] $dd_groups = $datadog_agent::params::dd_groups,
  Boolean $apm_enabled = $datadog_agent::params::apm_default_enabled,
  String $apm_env = 'none',
  Boolean $apm_non_local_traffic = false,
  Optional[Hash[String, Float[0, 1]]] $apm_analyzed_spans = undef,
  Optional[Hash[String, Data]] $apm_obfuscation = undef,
  Boolean $process_enabled = $datadog_agent::params::process_default_enabled,
  Boolean $scrub_args = $datadog_agent::params::process_default_scrub_args,
  Array $custom_sensitive_words = $datadog_agent::params::process_default_custom_words,
  Boolean $logs_enabled = $datadog_agent::params::logs_enabled,
  Optional[Integer] $logs_open_files_limit = $datadog_agent::params::logs_open_files_limit,
  Boolean $container_collect_all = $datadog_agent::params::container_collect_all,
  Hash[String[1], Data] $agent_extra_options = {},
  Optional[String] $agent_repo_uri = undef,
  Optional[Boolean] $rpm_repo_gpgcheck = undef,
  # TODO: $use_apt_backup_keyserver, $apt_backup_keyserver and $apt_keyserver can be
  # removed in the next major version; they're kept now for backwards compatibility
  Optional[Boolean] $use_apt_backup_keyserver = undef,
  Optional[String] $apt_backup_keyserver = undef,
  Optional[String] $apt_keyserver = undef,
  String $apt_release = $datadog_agent::params::apt_default_release,
  String $win_msi_location = 'C:/Windows/temp', # Temporary directory where the msi file is downloaded, must exist
  Enum['present', 'absent'] $win_ensure = 'present', #TODO: Implement uninstall also for apt and rpm install methods
  Optional[String] $service_provider = undef,
  Optional[String] $agent_version = $datadog_agent::params::agent_version,
  Boolean $windows_npm_install = false,
  Optional[String] $windows_ddagentuser_name = undef,
  Optional[String] $windows_ddagentuser_password = undef,
) inherits datadog_agent::params {
  #In this regex, version '1:6.15.0~rc.1-1' would match as $1='1:', $2='6', $3='15', $4='0', $5='~rc.1', $6='1'
  if $agent_version != 'latest' and $agent_version =~ /([0-9]+:)?([0-9]+)\.([0-9]+)\.([0-9]+)((?:~|-)[^0-9\s-]+[^-\s]*)?(?:-([0-9]+))?/ {
    $_agent_major_version = 0 + $2 # Cast to integer
    if $agent_major_version != undef and $agent_major_version != $_agent_major_version {
      fail('Provided and deduced agent_major_version don\'t match')
    }
  } elsif $agent_major_version != undef {
    $_agent_major_version = $agent_major_version
  } else {
    $_agent_major_version = $datadog_agent::params::default_agent_major_version
  }

  if versioncmp($_agent_major_version, '5') < 0 or versioncmp($_agent_major_version, '7') > 0 {
    fail("agent_major_version must be either 5, 6 or 7, not ${_agent_major_version}")
  }

  if ($facts['os']['name'] == 'Windows' and $windows_ddagentuser_name != undef) {
    $dd_user = $windows_ddagentuser_name
  } else {
    $dd_user = $datadog_agent::params::dd_user
  }

  if $conf_dir == undef {
    if versioncmp($_agent_major_version, '5') == 0 {
      $_conf_dir = $datadog_agent::params::legacy_conf_dir
    } else {
      $_conf_dir = $datadog_agent::params::conf_dir
    }
  } else {
    $_conf_dir = $conf_dir
  }

  if $hiera_tags {
    $local_tags = lookup({ 'name' => 'datadog_agent::tags', 'merge' => 'unique', 'default_value' => [] })
  } else {
    $local_tags = $tags
  }

  if $hiera_integrations {
    $local_integrations = lookup({ 'name' => 'datadog_agent::integrations', 'default_value' => {} })
  } else {
    $local_integrations = $integrations
  }

  include datadog_agent::params
  case upcase($log_level) {
    'CRITICAL': { $_loglevel = 'CRITICAL' }
    'DEBUG':    { $_loglevel = 'DEBUG' }
    'ERROR':    { $_loglevel = 'ERROR' }
    'FATAL':    { $_loglevel = 'FATAL' }
    'INFO':     { $_loglevel = 'INFO' }
    'WARN':     { $_loglevel = 'WARN' }
    'WARNING':  { $_loglevel = 'WARNING' }
    default:    { $_loglevel = 'INFO' }
  }

  # Install agent
  if $manage_install {
    case $facts['os']['name'] {
      'Ubuntu','Debian','Raspbian' : {
        if $use_apt_backup_keyserver != undef or $apt_backup_keyserver != undef or $apt_keyserver != undef {
          notify { 'apt keyserver arguments deprecation':
            message  => '$use_apt_backup_keyserver, $apt_backup_keyserver and $apt_keyserver are deprecated since version 3.13.0',
            loglevel => 'warning',
          }
        }
        class { 'datadog_agent::ubuntu':
          agent_major_version   => $_agent_major_version,
          agent_version         => $agent_version,
          agent_flavor          => $agent_flavor,
          agent_repo_uri        => $agent_repo_uri,
          release               => $apt_release,
          skip_apt_key_trusting => $skip_apt_key_trusting,
        }
      }
      'RedHat','CentOS','Fedora','Amazon','Scientific','OracleLinux','AlmaLinux','Rocky' : {
        class { 'datadog_agent::redhat':
          agent_major_version => $_agent_major_version,
          agent_flavor        => $agent_flavor,
          agent_repo_uri      => $agent_repo_uri,
          manage_repo         => $manage_repo,
          agent_version       => $agent_version,
          rpm_repo_gpgcheck   => $rpm_repo_gpgcheck,
        }
      }
      'Windows' : {
        class { 'datadog_agent::windows' :
          agent_major_version  => $_agent_major_version,
          agent_repo_uri       => $agent_repo_uri,
          agent_version        => $agent_version,
          msi_location         => $win_msi_location,
          api_key              => $api_key,
          hostname             => $host,
          tags                 => $local_tags,
          ensure               => $win_ensure,
          npm_install          => $windows_npm_install,
          ddagentuser_name     => $windows_ddagentuser_name,
          ddagentuser_password => $windows_ddagentuser_password,
        }
        if ($win_ensure == absent) {
          return() #Config files will remain unchanged on uninstall
        }
      }
      'OpenSuSE', 'SLES' : {
        class { 'datadog_agent::suse' :
          agent_major_version => $_agent_major_version,
          agent_flavor        => $agent_flavor,
          agent_repo_uri      => $agent_repo_uri,
          agent_version       => $agent_version,
          rpm_repo_gpgcheck   => $rpm_repo_gpgcheck,
        }
      }
      default: { fail("Class[datadog_agent]: Unsupported operatingsystem: ${facts['os']['name']}") }
    }
  } else {
    if ! defined(Package[$agent_flavor]) {
      package { $agent_flavor:
        ensure => present,
        source => 'Agent installation not managed by Puppet, make sure the Agent is installed beforehand.',
      }
    }
  }

  # Declare service
  class { 'datadog_agent::service' :
    agent_flavor     => $agent_flavor,
    service_ensure   => $service_ensure,
    service_enable   => $service_enable,
    service_provider => $service_provider,
  }

  if ($facts['os']['name'] != 'Windows') {
    if ($dd_groups) {
      user { $dd_user:
        groups => $dd_groups,
        notify => Service[$datadog_agent::params::service_name],
      }
    }

    # required by reports even in agent5 scenario
    file { '/etc/datadog-agent':
      ensure  => directory,
      owner   => $dd_user,
      group   => $dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$agent_flavor],
    }
  }

  if versioncmp($_agent_major_version, '5') == 0 {
    if ($facts['os']['name'] == 'Windows') {
      fail('Installation of agent 5 with puppet is not supported on Windows')
    }

    if !empty($agent_extra_options) {
      notify { 'Setting agent_extra_options has no effect with Agent 5': }
    }

    file { '/etc/dd-agent':
      ensure  => directory,
      owner   => $dd_user,
      group   => $dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$agent_flavor],
    }

    file { $_conf_dir:
      ensure  => directory,
      purge   => $conf_dir_purge,
      recurse => true,
      force   => $conf_dir_purge,
      owner   => $dd_user,
      group   => $dd_group,
      notify  => Service[$datadog_agent::params::service_name],
    }

    concat { '/etc/dd-agent/datadog.conf':
      owner   => $dd_user,
      group   => $dd_group,
      mode    => '0640',
      notify  => Service[$datadog_agent::params::service_name],
      require => File['/etc/dd-agent'],
    }

    if $dd_url.empty {
      $_dd_url = 'https://app.datadoghq.com'
    } else {
      $_dd_url = $dd_url
    }
    concat::fragment { 'datadog header':
      target  => '/etc/dd-agent/datadog.conf',
      content => template('datadog_agent/datadog_header.conf.erb'),
      order   => '01',
    }

    concat::fragment { 'datadog tags':
      target  => '/etc/dd-agent/datadog.conf',
      content => 'tags: ',
      order   => '02',
    }

    datadog_agent::tag5 { $local_tags: }
    datadog_agent::tag5 { $facts_to_tags:
      lookup_fact => true,
    }

    concat::fragment { 'datadog footer':
      target  => '/etc/dd-agent/datadog.conf',
      content => template('datadog_agent/datadog_footer.conf.erb'),
      order   => '05',
    }

    unless $extra_template.empty {
      concat::fragment { 'datadog extra_template footer':
        target  => '/etc/dd-agent/datadog.conf',
        content => template($extra_template),
        order   => '06',
      }
    }

    if ($apm_enabled == true) and (($apm_env != 'none') or $apm_analyzed_spans or $apm_obfuscation) {
      concat::fragment { 'datadog apm footer':
        target  => '/etc/dd-agent/datadog.conf',
        content => template('datadog_agent/datadog_apm_footer.conf.erb'),
        order   => '07',
      }
    }

    if ($process_enabled == true) {
      concat::fragment { 'datadog process agent footer':
        target  => '/etc/dd-agent/datadog.conf',
        content => template('datadog_agent/datadog_process_footer.conf.erb'),
        order   => '08',
      }
    }

    file { '/etc/dd-agent/install_info':
      owner   => $dd_user,
      group   => $dd_group,
      mode    => '0640',
      content => template('datadog_agent/install_info.erb'),
      require => File['/etc/dd-agent'],
    }
  } else { #Agent 6/7

    # notify of broken params on agent6/7
    if !empty($proxy_host) {
      notify { 'Setting proxy_host is only used with Agent 5. Please use agent_extra_options to set your proxy': }
    }
    if !empty($proxy_port) {
      notify { 'Setting proxy_port is only used with Agent 5. Please use agent_extra_options to set your proxy': }
    }
    if !empty($proxy_user) {
      notify { 'Setting proxy_user is only used with Agent 5. Please use agent_extra_options to set your proxy': }
    }
    if !empty($proxy_password) {
      notify { 'Setting proxy_password is only used with Agent 5. Please use agent_extra_options to set your proxy': }
    }

    # lint:ignore:quoted_booleans
    $process_enabled_str = $process_enabled ? { true => 'true' , default => 'disabled' }
    # lint:endignore
    $base_extra_config = {
      'apm_config' => {
        'enabled'               => $apm_enabled,
        'env'                   => $apm_env,
        'apm_non_local_traffic' => $apm_non_local_traffic,
      },
      'process_config' => {
        'enabled' => $process_enabled_str,
        'scrub_args' => $scrub_args,
        'custom_sensitive_words' => $custom_sensitive_words,
      },
      'logs_enabled' => $logs_enabled,
    }
    if $logs_open_files_limit {
      $logs_base_config = {
        'logs_config' => {
          'container_collect_all' => $container_collect_all,
          'open_files_limit' => $logs_open_files_limit,
        },
      }
    } else {
      $logs_base_config = {
        'logs_config' => {
          'container_collect_all' => $container_collect_all,
        },
      }
    }
    if $host.empty {
      $host_config = {}
    } else {
      $host_config = {
        'hostname' => $host,
      }
    }

    if $apm_analyzed_spans {
      $apm_analyzed_span_config = {
        'apm_config' => {
          'analyzed_spans' => $apm_analyzed_spans,
        },
      }
    } else {
      $apm_analyzed_span_config = {}
    }

    if $apm_obfuscation {
      $apm_obfuscation_config = {
        'apm_config' => {
          'obfuscation' => $apm_obfuscation,
        },
      }
    } else {
      $apm_obfuscation_config = {}
    }

    if $statsd_forward_host.empty {
      $statsd_forward_config = {}
    } else {
      if String($statsd_forward_port).empty {
        $statsd_forward_config = {
          'statsd_forward_host' => $statsd_forward_host,
        }
      } else {
        $statsd_forward_config = {
          'statsd_forward_host' => $statsd_forward_host,
          'statsd_forward_port' => $statsd_forward_port,
        }
      }
    }

    if $additional_checksd {
      $additional_checksd_config = {
        'additional_checksd' => $additional_checksd,
      }
    } else {
      $additional_checksd_config = {}
    }

    $extra_config = deep_merge(
      $base_extra_config,
      $logs_base_config,
      $agent_extra_options,
      $apm_analyzed_span_config,
      $apm_obfuscation_config,
      $statsd_forward_config,
      $host_config,
    $additional_checksd_config)

    file { $_conf_dir:
      ensure  => directory,
      purge   => $conf_dir_purge,
      recurse => true,
      force   => $conf_dir_purge,
      owner   => $dd_user,
      group   => $dd_group,
      notify  => Service[$datadog_agent::params::service_name],
    }

    $_local_tags = datadog_agent::tag6($local_tags, false, undef)
    $_facts_tags = datadog_agent::tag6($facts_to_tags, true, $facts)
    $_trusted_facts_tags = datadog_agent::tag6($trusted_facts_to_tags, true, $trusted)

    $_agent_config = {
      'api_key' => $api_key,
      'dd_url' => $dd_url,
      'site' => $datadog_site,
      'cmd_port' => $cmd_port,
      'hostname_fqdn' => $hostname_fqdn,
      'collect_ec2_tags' => $collect_ec2_tags,
      'collect_gce_tags' => $collect_gce_tags,
      'confd_path' => $_conf_dir,
      'enable_metadata_collection' => $collect_instance_metadata,
      'dogstatsd_port' => $dogstatsd_port,
      'dogstatsd_socket' => $dogstatsd_socket,
      'dogstatsd_non_local_traffic' => $non_local_traffic,
      'log_file' => $agent_log_file,
      'log_level' => $log_level,
      'tags' => unique(flatten(union($_local_tags, $_facts_tags, $_trusted_facts_tags))),
    }

    $agent_config = deep_merge($_agent_config, $extra_config)

    if ($facts['os']['name'] == 'Windows') {
      file { 'C:/ProgramData/Datadog':
        ensure   => directory,
      }

      file { 'C:/ProgramData/Datadog/datadog.yaml':
        owner     => $dd_user,
        group     => $dd_group,
        mode      => '0660',
        content   => template('datadog_agent/datadog.yaml.erb'),
        show_diff => false,
        notify    => Service[$datadog_agent::params::service_name],
        require   => File['C:/ProgramData/Datadog'],
      }

      file { 'C:/ProgramData/Datadog/install_info':
        owner   => $dd_user,
        group   => $dd_group,
        mode    => '0660',
        content => template('datadog_agent/install_info.erb'),
        require => File['C:/ProgramData/Datadog'],
      }
    } else {
      file { '/etc/datadog-agent/datadog.yaml':
        owner     => $dd_user,
        group     => $dd_group,
        mode      => '0640',
        content   => template('datadog_agent/datadog.yaml.erb'),
        show_diff => false,
        notify    => Service[$datadog_agent::params::service_name],
        require   => File['/etc/datadog-agent'],
      }

      file { '/etc/datadog-agent/install_info':
        owner   => $dd_user,
        group   => $dd_group,
        mode    => '0640',
        content => template('datadog_agent/install_info.erb'),
        require => File['/etc/datadog-agent'],
      }
    }
  }

  if $puppet_run_reports {
    $proxy_config = $agent_extra_options[proxy]
    if $proxy_config != undef {
      $proxy_http = $proxy_config[http]
      $proxy_https = $proxy_config[https]
    } else {
      $proxy_http = undef
      $proxy_https = undef
    }

    class { 'datadog_agent::reports':
      api_key                   => $api_key,
      datadog_site              => $reports_url,
      manage_dogapi_gem         => $manage_dogapi_gem,
      puppet_gem_provider       => $puppet_gem_provider,
      dogapi_version            => $datadog_agent::params::dogapi_version,
      puppetmaster_user         => $puppetmaster_user,
      hostname_extraction_regex => $hostname_extraction_regex,
      proxy_http                => $proxy_http,
      proxy_https               => $proxy_https,
      report_fact_tags          => $report_fact_tags,
      report_trusted_fact_tags  => $report_trusted_fact_tags,
    }
  }

  create_resources('datadog_agent::integration', $local_integrations)
}
