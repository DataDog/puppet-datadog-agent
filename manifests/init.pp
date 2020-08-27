# Class: datadog_agent
#
# This class contains the agent installation mechanism for the Datadog module
#
# Parameters:
#   $dd_url:
#       The host of the Datadog intake server to send agent data to.
#       Defaults to https://app.datadoghq.com.
#   $datadog_site:
#       The site of the Datadog intake to send Agent data to. Defaults to 'datadoghq.com',
#       set to 'datadoghq.eu' to send data to the EU site.
#       This option is only available with agent version >= 6.6.0.
#   $host:
#       Force the hostname to whatever you want. (default: auto-detected)
#   $api_key:
#       Your DataDog API Key. Please replace with your key value.
#   $collect_ec2_tags
#       Collect AWS EC2 custom tags as agent tags.
#       Boolean. Default: false
#   $collect_gce_tags
#       Collect Google Cloud Engine metadata as agent tags.
#       Boolean. Default: false
#   $collect_instance_metadata
#       The Agent will try to collect instance metadata for EC2 and GCE instances.
#       Boolean. Default: true
#   $tags
#       Optional array of tags.
#   $hiera_tags
#       Boolean to grab tags from hiera to allow merging
#   $facts_to_tags
#       Optional array of facts' names that you can use to define tags following
#       the scheme: "fact_name:fact_value".
#   $puppet_run_reports
#       Will send results from your puppet agent runs back to the datadog service.
#   $manage_dogapi_gem
#       When reports are enabled, ensure the dogapi gem (required) is installed.
#   $puppetmaster_user
#       Will chown the api key used by the report processor to this user.
#       Defaults to the user the puppetmaster is configured to run as.
#   $non_local_traffic
#       Enable you to use the agent as a proxy. Defaults to false.
#       See https://github.com/DataDog/dd-agent/wiki/Proxy-Configuration
#   $dogstreams
#       Optional array of logs to parse and custom parsers to use.
#       See https://github.com/DataDog/dd-agent/blob/ed5e698/datadog.conf.example#L149-L178
#   $log_level
#       Set value of 'log_level' variable. Default is 'info' as in dd-agent.
#       Valid values here are: critical, debug, error, fatal, info, warn and warning.
#   $hostname_extraction_regex
#       Completely optional.
#       Instead of reporting the puppet nodename, use this regex to extract the named
#       'hostname' captured group to report the run in Datadog.
#       ex.: '^(?<hostname>.*\.datadoghq\.com)(\.i-\w{8}\..*)?$'
#   $hostname_fqdn
#       Make the agent use "hostname -f" on unix-based systems as a last resort
#       way of determining the hostname instead of Golang "os.Hostname()"
#       This will be enabled by default in version 6.6
#       More information at  https://dtdg.co/flag-hostname-fqdn
#       Optional: Valid values here are: true or false.
#   $log_to_syslog
#       Set value of 'log_to_syslog' variable. Default is true -> yes as in dd-agent.
#       Valid values here are: true or false.
#   $dogstatsd_port
#       Set value of the 'dogstatsd_port' variable. Defaultis 8125.
#   $report_fact_tags
#       Sets tags for report events sent to Datadog from specified facts
#   $statsd_forward_host
#       Set the value of the statsd_forward_host varable. Used to forward all
#       statsd metrics to another host.
#   $statsd_forward_port
#       Set the value of the statsd_forward_port varable. Used to forward all
#       statsd metrics to another host.
#   $manage_repo
#       Deprecated. Only works for RPM. Install datadog-agent manually and then set
#       manage_install=false to achieve the same behaviour as setting this to false.
#   $manage_install
#       Boolean to indicate whether this module should attempt to install the
#       Agent, or assume it will be installed by other means. Default true.
#   $graphite_listen_port
#       Set graphite listener port
#   $extra_template
#       Optional, append this extra template file at the end of
#       the default datadog.conf template
#   $skip_apt_key_trusting
#       Skip trusting the apt key. Default is false. Useful if you have a
#       separate way of adding keys.
#   $skip_ssl_validation
#       Skip SSL validation.
#   $use_curl_http_client
#       Uses the curl HTTP client for the forwarder
#   $recent_point_threshold
#       Sets the threshold for accepting points.
#   String. Default: empty (30 second intervals)
#   $listen_port
#       Change the port that the agent listens on
#       String. Default: empty (port 17123 in dd-agent)
#   $additional_checksd
#       Additional directory to look for datadog checks in
#       String. Default: undef
#   $bind_host
#       The loopback address the forwarder and Dogstatsd will bind.
#       String. Default: empty
#   $use_pup
#       Enables the local pup dashboard
#       Boolean. Default: false
#   $pup_port
#       Specifies the port to be used by pup. Must have use_pup set
#       String. Default: empty
#   $pup_interface
#       Specifies which interface pup will use. Must have use_pup set
#       String. Default: empty
#   $pup_url
#       Specifies the URL used to access pup. Must have use_pup set
#       String. Default: empty
#   $use_dogstatsd
#       Enables the dogstatsd server
#       Boolean. Default: true
#   $dogstatsd_socket
#       Specifies the socket file to be used by dogstatsd. Must have use_dogstatsd set
#       String. Default: empty
#   $dogstatsd_port
#       Specifies the port to be used by dogstatsd. Must have use_dogstatsd set
#       String. Default: empty
#   $dogstatsd_target
#       Change the target to be used by dogstatsd. Must have use_dogstatsd set
#       set
#       String. Default: empty
#   $dogstatsd_interval
#       Change the dogstatsd flush period. Must have use_dogstatsd set
#       String. Default: empty ( 10 second interval)
#   $dogstatsd_normalize
#       Enables 1 second nomralization. Must have use_dogstatsd set
#       Boolean. Default: true
#   $statsd_forward_host
#       Enables forwarding of statsd packetsto host. Must have use_dogstatsd set
#       String. Default: empty
#   $statsd_forward_port
#       Specifis port for $statsd_forward_host. Must have use_dogstatsd set
#       String. Default: empty
#   $device_blacklist_re
#       Specifies pattern for device blacklisting.
#       String. Default: empty
#   $ganglia_host
#       Specifies host where gmetad is running
#       String. Default: empty
#   $ganglia_port
#       Specifies port  for $ganglia_host
#       String. Default: empty
#   $dogstreams
#       Specifies port for list of logstreams/modules to be used.
#       String. Default: empty
#   $custom_emitters
#       Specifies a comma seperated list of non standard emitters to be used
#       String. Default: empty
#   $custom_emitters
#       Specifies a comma seperated list of non standard emitters to be used
#       String. Default: empty
#   $agent_log_file
#       Specifies the log file location (Agent 6 and 7 only).
#       String. Default: empty
#   $collector_log_file
#       Specifies the log file location for the collector system
#       String. Default: empty
#   $forwarder_log_file
#       Specifies the log file location for the forwarder system
#       String. Default: empty
#   $dogstatsd
#       Specifies the log file location for the dogstatsd system
#       String. Default: empty
#   $pup_log_file
#       Specifies the log file location for the pup system
#       String. Default: empty
#   $apm_enabled
#       Boolean to enable or disable the trace agent
#       Boolean. Default: false
#   $apm_env
#       String defining the environment for the APM traces
#       String. Default: non
#   $apm_non_local_traffic
#       Accept non local apm traffic. Defaults to false.
#       Boolean. Default: false
#   $apm_analyzed_spans
#       Hash defining the APM spans to analyze and their rates.
#       Optional Hash. Default: undef.
#   $apm_obfuscation
#       Hash defining obfuscation rules for sensitive data. (Agent 6 and 7 only).
#       Optional Hash. Default: undef
#   $process_enabled
#       String to enable the process/container agent
#       Boolean. Default: false
#   $scrub_args
#       Boolean to enable or disable the process cmdline scrubbing by the process-agent
#       Boolean. Default: true
#   $custom_sensitive_words
#       Array to add more words to be used on the process cdmline scrubbing by the process-agent
#       Array. Default: []
#   $logs_enabled
#       Boolean to enable or disable the logs agent
#       Boolean. Default: false
#   $logs_open_files_limit
#       Integer set the max number of open files for the logs agent
#       Integer. Default: 100 if undef
#   $container_collect_all
#       Boolean to enable logs collection for all containers
#       Boolean. Default: false
#   $cmd_port
#       The port on which the IPC api listens
#       Integer. Default: 5001
#   $agent_repo_uri
#       Where to download the agent from. When undef, it uses the following defaults:
#       APT: https://apt.datadoghq.com/
#       RPM: https://yum.datadoghq.com/stable/7/x86_64/ (with matching agent version and architecture)
#       Windows: https://https://s3.amazonaws.com/ddagent-windows-stable/
#       String. Default: undef
#   $apt_release
#       The distribution channel to be used for the APT repo. Eg: 'stable' or 'beta'.
#       String. Default: stable
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
class datadog_agent(
  String $dd_url = '',
  String $datadog_site = $datadog_agent::params::datadog_site,
  String $host = '',
  String $api_key = 'your_API_key',
  Boolean $collect_ec2_tags = false,
  Boolean $collect_gce_tags = false,
  Boolean $collect_instance_metadata = true,
  Array $tags = [],
  $integrations = {},
  $hiera_integrations = false,
  Boolean $hiera_tags = false,
  Array $facts_to_tags = [],
  Boolean $puppet_run_reports = false,
  String $puppetmaster_user = $settings::user,
  String $puppet_gem_provider = $datadog_agent::params::gem_provider,
  Boolean $non_local_traffic = false,
  Array $dogstreams = [],
  String $log_level = 'info',
  Boolean $log_to_syslog = true,
  $service_ensure = 'running',
  $service_enable = true,
  Boolean $manage_repo = true,
  Boolean $manage_dogapi_gem = true,
  Boolean $manage_install = true,
  $hostname_extraction_regex = undef,
  Boolean $hostname_fqdn = false,
  $dogstatsd_port = 8125,
  $dogstatsd_socket = '',
  Array $report_fact_tags = [],
  String $statsd_forward_host = '',
  $statsd_forward_port = '',
  String $statsd_histogram_percentiles = '0.95',
  Optional[String] $proxy_host = undef,
  Optional[Variant[Integer, Pattern[/^\d*$/]]] $proxy_port = undef,
  Optional[String] $proxy_user = undef,
  Optional[String] $proxy_password = undef,
  $graphite_listen_port = '',
  String $extra_template = '',
  String $ganglia_host = '',
  $ganglia_port = 8651,
  Boolean $skip_ssl_validation = false,
  Boolean $skip_apt_key_trusting = false,
  Boolean $use_curl_http_client = false,
  String $recent_point_threshold = '',
  $listen_port = '',
  Optional[String] $additional_checksd = undef,
  String $bind_host = '',
  Boolean $use_pup = false,
  $pup_port = '',
  String $pup_interface = '',
  String $pup_url = '',
  Boolean $use_dogstatsd = true,
  String $dogstatsd_target = '',
  String $dogstatsd_interval = '',
  Boolean $dogstatsd_normalize = true,
  String $device_blacklist_re = '',
  String $custom_emitters = '',
  String $agent_log_file = $datadog_agent::params::agent_log_file,
  String $collector_log_file = '',
  String $forwarder_log_file = '',
  String $dogstatsd_log_file = '',
  String $pup_log_file = '',
  String $syslog_host  = '',
  $syslog_port  = '',
  String $service_discovery_backend = '',
  String $sd_config_backend = '',
  String $sd_backend_host = '',
  Integer $sd_backend_port = 0,
  String $sd_template_dir = '',
  Boolean $sd_jmx_enable = false,
  String $consul_token = '',
  Integer $cmd_port = 5001,
  Optional[Integer] $agent_major_version = undef,
  Optional[String] $conf_dir = undef,
  Boolean $conf_dir_purge = $datadog_agent::params::conf_dir_purge,
  $dd_user = $datadog_agent::params::dd_user,
  $dd_group = $datadog_agent::params::dd_group,
  $dd_groups = $datadog_agent::params::dd_groups,
  Boolean $apm_enabled = $datadog_agent::params::apm_default_enabled,
  String $apm_env = 'none',
  Boolean $apm_non_local_traffic = false,
  Optional[Hash[String, Float[0, 1]]] $apm_analyzed_spans = undef,
  Optional[Hash[String, Data]] $apm_obfuscation = undef,
  Boolean $process_enabled = $datadog_agent::params::process_default_enabled,
  Boolean $scrub_args = $datadog_agent::params::process_default_scrub_args,
  Array $custom_sensitive_words = $datadog_agent::params::process_default_custom_words,
  Boolean $logs_enabled = $datadog_agent::params::logs_enabled,
  $logs_open_files_limit = $datadog_agent::params::logs_open_files_limit,
  Boolean $container_collect_all = $datadog_agent::params::container_collect_all,
  Hash[String[1], Data] $agent_extra_options = {},
  Optional[String] $agent_repo_uri = undef,
  Optional[Boolean] $use_apt_backup_keyserver = $datadog_agent::params::use_apt_backup_keyserver,
  String $apt_backup_keyserver = $datadog_agent::params::apt_backup_keyserver,
  String $apt_keyserver = $datadog_agent::params::apt_keyserver,
  String $apt_release = $datadog_agent::params::apt_default_release,
  String $win_msi_location = 'C:/Windows/temp', # Temporary directory where the msi file is downloaded, must exist
  Enum['present', 'absent'] $win_ensure = 'present', #TODO: Implement uninstall also for apt and rpm install methods
  Optional[String] $service_provider = undef,
  Optional[String] $agent_version = $datadog_agent::params::agent_version,
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

  if $_agent_major_version != 5 and $_agent_major_version != 6 and $_agent_major_version != 7 {
    fail('agent_major_version must be either 5, 6 or 7')
  }

  # Allow ports to be passed as integers or strings.
  # lint:ignore:only_variable_string
  $_dogstatsd_port = "${dogstatsd_port}"
  $_statsd_forward_port = "${statsd_forward_port}"
  $_graphite_listen_port = "${graphite_listen_port}"
  $_listen_port = "${listen_port}"
  $_pup_port = "${pup_port}"
  $_syslog_port = "${syslog_port}"
  # lint:endignore

  validate_legacy(String, 'validate_re', $_dogstatsd_port, '^\d*$')
  validate_legacy(String, 'validate_re', $_statsd_forward_port, '^\d*$')
  validate_legacy(String, 'validate_re', $_graphite_listen_port, '^\d*$')
  validate_legacy(String, 'validate_re', $_listen_port, '^\d*$')
  validate_legacy(String, 'validate_re', $_pup_port, '^\d*$')
  validate_legacy(String, 'validate_re', $_syslog_port, '^\d*$')

  if $conf_dir == undef {
    if $_agent_major_version == 5 {
      $_conf_dir = $datadog_agent::params::legacy_conf_dir
    } else {
      $_conf_dir = $datadog_agent::params::conf_dir
    }
  } else {
    $_conf_dir = $conf_dir
  }

  if $hiera_tags {
    $local_tags = lookup({ 'name' => 'datadog_agent::tags', 'merge' => 'unique', 'default_value' => []})
  } else {
    $local_tags = $tags
  }

  if $hiera_integrations {
    $local_integrations = lookup({ 'name' => 'datadog_agent::integrations', 'default_value' => {}})
  } else {
    $local_integrations = $integrations
  }

  $_puppetversion = lookup({ 'name' => '::puppetversion', 'default_value' => 'unknown'})

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
    case $::operatingsystem {
      'Ubuntu','Debian' : {
        if $use_apt_backup_keyserver {
          $_apt_keyserver = $apt_backup_keyserver
        } else {
          $_apt_keyserver = $apt_keyserver
        }
        class { 'datadog_agent::ubuntu':
          agent_major_version   => $_agent_major_version,
          agent_version         => $agent_version,
          agent_repo_uri        => $agent_repo_uri,
          release               => $apt_release,
          skip_apt_key_trusting => $skip_apt_key_trusting,
          apt_keyserver         => $_apt_keyserver,
        }
      }
      'RedHat','CentOS','Fedora','Amazon','Scientific','OracleLinux' : {
        class { 'datadog_agent::redhat':
          agent_major_version => $_agent_major_version,
          agent_repo_uri      => $agent_repo_uri,
          manage_repo         => $manage_repo,
          agent_version       => $agent_version,
        }
      }
      'Windows' : {
        class { 'datadog_agent::windows' :
          agent_major_version => $_agent_major_version,
          agent_repo_uri      => $agent_repo_uri,
          agent_version       => $agent_version,
          msi_location        => $win_msi_location,
          api_key             => $api_key,
          hostname            => $host,
          tags                => $local_tags,
          ensure              => $win_ensure
        }
        if ($win_ensure == absent) {
          return() #Config files will remain unchanged on uninstall
        }
      }
      default: { fail("Class[datadog_agent]: Unsupported operatingsystem: ${::operatingsystem}") }
    }
  } else {
    package { $datadog_agent::params::package_name:
      ensure => present,
      source => 'Agent installation not managed by Puppet, make sure the Agent is installed beforehand.',
    }
  }

  # Declare service
  class { 'datadog_agent::service' :
    service_ensure   => $service_ensure,
    service_enable   => $service_enable,
    service_provider => $service_provider,
  }

  if ($::operatingsystem != 'Windows') {
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
      require => Package[$datadog_agent::params::package_name],
    }
  }

  if $_agent_major_version == 5 {

    if ($::operatingsystem == 'Windows') {
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
      require => Package[$datadog_agent::params::package_name],
    }

    file { $_conf_dir:
      ensure  => directory,
      purge   => $conf_dir_purge,
      recurse => true,
      force   => $conf_dir_purge,
      owner   => $dd_user,
      group   => $dd_group,
      notify  => Service[$datadog_agent::params::service_name]
    }

    concat {'/etc/dd-agent/datadog.conf':
      owner   => $dd_user,
      group   => $dd_group,
      mode    => '0640',
      notify  => Service[$datadog_agent::params::service_name],
      require => File['/etc/dd-agent'],
    }

    if ($dd_url == '') {
      $_dd_url = 'https://app.datadoghq.com'
    } else {
      $_dd_url = $dd_url
    }
    concat::fragment{ 'datadog header':
      target  => '/etc/dd-agent/datadog.conf',
      content => template('datadog_agent/datadog_header.conf.erb'),
      order   => '01',
    }

    concat::fragment{ 'datadog tags':
      target  => '/etc/dd-agent/datadog.conf',
      content => 'tags: ',
      order   => '02',
    }

    datadog_agent::tag5{$local_tags: }
    datadog_agent::tag5{$facts_to_tags:
      lookup_fact => true,
    }

    concat::fragment{ 'datadog footer':
      target  => '/etc/dd-agent/datadog.conf',
      content => template('datadog_agent/datadog_footer.conf.erb'),
      order   => '05',
    }

    if ($extra_template != '') {
      concat::fragment{ 'datadog extra_template footer':
        target  => '/etc/dd-agent/datadog.conf',
        content => template($extra_template),
        order   => '06',
      }
    }

    if ($apm_enabled == true) and (($apm_env != 'none') or $apm_analyzed_spans or $apm_obfuscation) {
      concat::fragment{ 'datadog apm footer':
        target  => '/etc/dd-agent/datadog.conf',
        content => template('datadog_agent/datadog_apm_footer.conf.erb'),
        order   => '07',
      }
    }

    if ($process_enabled == true) {
      concat::fragment{ 'datadog process agent footer':
        target  => '/etc/dd-agent/datadog.conf',
        content => template('datadog_agent/datadog_process_footer.conf.erb'),
        order   => '08',
      }
    }

    file {'/etc/dd-agent/install_info':
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
          'apm_non_local_traffic' => $apm_non_local_traffic
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
          'open_files_limit' => $logs_open_files_limit
        },
      }
    } else {
      $logs_base_config = {
        'logs_config' => {
          'container_collect_all' => $container_collect_all,
        },
      }
    }
    if $host != '' {
        $host_config = {
          'hostname' => $host,
        }
    } else {
        $host_config = {}
    }

    if $apm_analyzed_spans {
        $apm_analyzed_span_config = {
            'apm_config' => {
                'analyzed_spans' => $apm_analyzed_spans
            }
        }
    } else {
        $apm_analyzed_span_config = {}
    }

    if $apm_obfuscation {
        $apm_obfuscation_config = {
          'apm_config' => {
            'obfuscation' => $apm_obfuscation
          }
        }
    } else {
        $apm_obfuscation_config = {}
    }

    if $statsd_forward_host != '' {
        if $_statsd_forward_port != '' {
            $statsd_forward_config = {
              'statsd_forward_host' => $statsd_forward_host,
              'statsd_forward_port' => $statsd_forward_port,
            }
        } else {
            $statsd_forward_config = {
              'statsd_forward_host' => $statsd_forward_host,
            }
        }
    } else {
        $statsd_forward_config = {}
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
      notify  => Service[$datadog_agent::params::service_name]
    }

    $_local_tags = datadog_agent::tag6($local_tags, false)
    $_facts_tags = datadog_agent::tag6($facts_to_tags, true)

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
      'tags' => unique(flatten(union($_local_tags, $_facts_tags))),
    }

    $agent_config = deep_merge($_agent_config, $extra_config)


    if ($::operatingsystem == 'Windows') {

      file { 'C:/ProgramData/Datadog':
        ensure   => directory
      }

      file { 'C:/ProgramData/Datadog/datadog.yaml':
        owner   => $dd_user,
        group   => $dd_group,
        mode    => '0660',
        content => template('datadog_agent/datadog.yaml.erb'),
        notify  => Service[$datadog_agent::params::service_name],
        require => File['C:/ProgramData/Datadog'],
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
        owner   => $dd_user,
        group   => $dd_group,
        mode    => '0640',
        content => template('datadog_agent/datadog.yaml.erb'),
        notify  => Service[$datadog_agent::params::service_name],
        require => File['/etc/datadog-agent'],
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
      datadog_site              => $datadog_site,
      manage_dogapi_gem         => $manage_dogapi_gem,
      puppet_gem_provider       => $puppet_gem_provider,
      dogapi_version            => $datadog_agent::params::dogapi_version,
      puppetmaster_user         => $puppetmaster_user,
      hostname_extraction_regex => $hostname_extraction_regex,
      proxy_http                => $proxy_http,
      proxy_https               => $proxy_https,
      report_fact_tags          => $report_fact_tags,
    }
  }

  create_resources('datadog_agent::integration', $local_integrations)

}
