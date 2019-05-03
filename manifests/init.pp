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
#   $statsd_forward_host
#       Set the value of the statsd_forward_host varable. Used to forward all
#       statsd metrics to another host.
#   $statsd_forward_port
#       Set the value of the statsd_forward_port varable. Used to forward all
#       statsd metrics to another host.
#   $manage_repo
#       Boolean to indicate whether this module should attempt to manage
#       the package repo. Default true.
#   $proxy_host
#       Set value of 'proxy_host' variable. Default is blank.
#   $proxy_port
#       Set value of 'proxy_port' variable. Default is blank.
#   $proxy_user
#       Set value of 'proxy_user' variable. Default is blank.
#   $proxy_password
#       Set value of 'proxy_password' variable. Default is blank.
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
#       String. Default: empty
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
#   $agent6_log_file
#       Specifies the log file location for the agent6
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
#   $container_collect_all
#       Boolean to enable logs collection for all containers
#       Boolean. Default: false
#   $cmd_port
#       The port on which the IPC api listens
#       Integer. Default: 5001
#
# Actions:
#
# Requires:
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
  $dd_url = '',
  $datadog_site = $datadog_agent::params::datadog_site,
  $host = '',
  $api_key = 'your_API_key',
  $collect_ec2_tags = false,
  $collect_gce_tags = false,
  $collect_instance_metadata = true,
  $tags = [],
  $integrations = {},
  $hiera_integrations = false,
  $hiera_tags = false,
  $facts_to_tags = [],
  $puppet_run_reports = false,
  $puppetmaster_user = $settings::user,
  String $puppet_gem_provider = $datadog_agent::params::gem_provider,
  $non_local_traffic = false,
  $dogstreams = [],
  $log_level = 'info',
  $log_to_syslog = true,
  $service_ensure = 'running',
  $service_enable = true,
  $manage_repo = true,
  $hostname_extraction_regex = undef,
  $hostname_fqdn = false,
  $dogstatsd_port = 8125,
  $dogstatsd_socket = '',
  $statsd_forward_host = '',
  $statsd_forward_port = '',
  $statsd_histogram_percentiles = '0.95',
  Optional[String] $proxy_host = undef,
  Optional[Variant[Integer, Pattern[/^\d*$/]]] $proxy_port = undef,
  Optional[String] $proxy_user = undef,
  Optional[String] $proxy_password = undef,
  $graphite_listen_port = '',
  $extra_template = '',
  $ganglia_host = '',
  $ganglia_port = 8651,
  $skip_ssl_validation = false,
  $skip_apt_key_trusting = false,
  $use_curl_http_client = false,
  $recent_point_threshold = '',
  $listen_port = '',
  $additional_checksd = '',
  $bind_host = '',
  $use_pup = false,
  $pup_port = '',
  $pup_interface = '',
  $pup_url = '',
  $use_dogstatsd = true,
  $dogstatsd_target = '',
  $dogstatsd_interval = '',
  $dogstatsd_normalize = true,
  $device_blacklist_re = '',
  $custom_emitters = '',
  $agent6_log_file = '/var/log/datadog/agent.log',
  $collector_log_file = '',
  $forwarder_log_file = '',
  $dogstatsd_log_file = '',
  $pup_log_file = '',
  $syslog_host  = '',
  $syslog_port  = '',
  $service_discovery_backend = '',
  $sd_config_backend = '',
  $sd_backend_host = '',
  $sd_backend_port = 0,
  $sd_template_dir = '',
  $sd_jmx_enable = false,
  $consul_token = '',
  $cmd_port = 5001,
  $agent5_enable = $datadog_agent::params::agent5_enable,
  $conf_dir = $datadog_agent::params::conf_dir,
  $conf6_dir = $datadog_agent::params::conf6_dir,
  $conf_dir_purge = $datadog_agent::params::conf_dir_purge,
  $service_name = $datadog_agent::params::service_name,
  $package_name = $datadog_agent::params::package_name,
  $dd_user = $datadog_agent::params::dd_user,
  $dd_group = $datadog_agent::params::dd_group,
  $dd_groups = $datadog_agent::params::dd_groups,
  $apm_enabled = $datadog_agent::params::apm_default_enabled,
  $apm_env = 'none',
  $apm_non_local_traffic = false,
  Optional[Hash[String, Float[0, 1]]] $apm_analyzed_spans = undef,
  $process_enabled = $datadog_agent::params::process_default_enabled,
  $scrub_args = $datadog_agent::params::process_default_scrub_args,
  $custom_sensitive_words = $datadog_agent::params::process_default_custom_words,
  $logs_enabled = $datadog_agent::params::logs_enabled,
  $container_collect_all = $datadog_agent::params::container_collect_all,
  Hash[String[1], Data] $agent6_extra_options = {},
  $agent5_repo_uri = $datadog_agent::params::agent5_default_repo,
  $agent6_repo_uri = $datadog_agent::params::agent6_default_repo,
  Optional[Boolean] $use_apt_backup_keyserver = $datadog_agent::params::use_apt_backup_keyserver,
  $apt_backup_keyserver = $datadog_agent::params::apt_backup_keyserver,
  $apt_keyserver = $datadog_agent::params::apt_keyserver,
  $apt_release = $datadog_agent::params::apt_default_release,
  Optional[String] $service_provider = undef,
  Optional[String] $agent_version = $datadog_agent::params::agent_version,
) inherits datadog_agent::params {

  # Allow ports to be passed as integers or strings.
  # lint:ignore:only_variable_string
  $_dogstatsd_port = "${dogstatsd_port}"
  $_statsd_forward_port = "${statsd_forward_port}"
  $_graphite_listen_port = "${graphite_listen_port}"
  $_listen_port = "${listen_port}"
  $_pup_port = "${pup_port}"
  $_syslog_port = "${syslog_port}"
  # lint:endignore

  validate_legacy(String, 'validate_string', $dd_url)
  validate_legacy(String, 'validate_string', $datadog_site)
  validate_legacy(String, 'validate_string', $host)
  validate_legacy(Boolean, 'validate_bool', $hostname_fqdn)
  validate_legacy(String, 'validate_string', $api_key)
  validate_legacy(Array, 'validate_array', $tags)
  validate_legacy(Boolean, 'validate_bool', $hiera_tags)
  validate_legacy(Array, 'validate_array', $dogstreams)
  validate_legacy(Array, 'validate_array', $facts_to_tags)
  validate_legacy(Boolean, 'validate_bool', $puppet_run_reports)
  validate_legacy(String, 'validate_string', $puppetmaster_user)
  validate_legacy(Boolean, 'validate_bool', $non_local_traffic)
  validate_legacy(Boolean, 'validate_bool', $log_to_syslog)
  validate_legacy(Boolean, 'validate_bool', $manage_repo)
  validate_legacy(String, 'validate_string', $log_level)
  validate_legacy(String, 'validate_re', $_dogstatsd_port, '^\d*$')
  validate_legacy(String, 'validate_string', $statsd_histogram_percentiles)
  validate_legacy(String, 'validate_re', $_statsd_forward_port, '^\d*$')
  validate_legacy(String, 'validate_re', $_graphite_listen_port, '^\d*$')
  validate_legacy(String, 'validate_string', $extra_template)
  validate_legacy(String, 'validate_string', $ganglia_host)
  validate_legacy(Integer, 'validate_integer', $ganglia_port)
  validate_legacy(Boolean, 'validate_bool', $skip_ssl_validation)
  validate_legacy(Boolean, 'validate_bool', $skip_apt_key_trusting)
  validate_legacy(Boolean, 'validate_bool', $use_curl_http_client)
  validate_legacy(Boolean, 'validate_bool', $collect_ec2_tags)
  validate_legacy(Boolean, 'validate_bool', $collect_gce_tags)
  validate_legacy(Boolean, 'validate_bool', $collect_instance_metadata)
  validate_legacy(String, 'validate_string', $recent_point_threshold)
  validate_legacy(String, 'validate_re', $_listen_port, '^\d*$')
  validate_legacy(String, 'validate_string', $additional_checksd)
  validate_legacy(String, 'validate_string', $bind_host)
  validate_legacy(Boolean, 'validate_bool', $use_pup)
  validate_legacy(String, 'validate_re', $_pup_port, '^\d*$')
  validate_legacy(String, 'validate_string', $pup_interface)
  validate_legacy(String, 'validate_string', $pup_url)
  validate_legacy(Boolean, 'validate_bool', $use_dogstatsd)
  validate_legacy(String, 'validate_string', $dogstatsd_target)
  validate_legacy(String, 'validate_string', $dogstatsd_interval)
  validate_legacy(Boolean, 'validate_bool', $dogstatsd_normalize)
  validate_legacy(String, 'validate_string', $statsd_forward_host)
  validate_legacy(String, 'validate_string', $device_blacklist_re)
  validate_legacy(String, 'validate_string', $custom_emitters)
  validate_legacy(String, 'validate_string', $agent6_log_file)
  validate_legacy(String, 'validate_string', $collector_log_file)
  validate_legacy(String, 'validate_string', $forwarder_log_file)
  validate_legacy(String, 'validate_string', $dogstatsd_log_file)
  validate_legacy(String, 'validate_string', $pup_log_file)
  validate_legacy(String, 'validate_string', $syslog_host)
  validate_legacy(String, 'validate_re', $_syslog_port, '^\d*$')
  validate_legacy(String, 'validate_string', $service_discovery_backend)
  validate_legacy(String, 'validate_string', $sd_config_backend)
  validate_legacy(String, 'validate_string', $sd_backend_host)
  validate_legacy(Integer, 'validate_integer', $sd_backend_port)
  validate_legacy(String, 'validate_string', $sd_template_dir)
  validate_legacy(Boolean, 'validate_bool', $sd_jmx_enable)
  validate_legacy(String, 'validate_string', $consul_token)
  validate_legacy(Boolean, 'validate_bool', $apm_enabled)
  validate_legacy(Boolean, 'validate_bool', $apm_non_local_traffic)
  validate_legacy(Boolean, 'validate_bool', $agent5_enable)
  validate_legacy(String, 'validate_string', $apm_env)
  validate_legacy(Boolean, 'validate_bool', $process_enabled)
  validate_legacy(Boolean, 'validate_bool', $scrub_args)
  validate_legacy(Array, 'validate_array', $custom_sensitive_words)
  validate_legacy(Boolean, 'validate_bool', $logs_enabled)
  validate_legacy(Boolean, 'validate_bool', $container_collect_all)
  validate_legacy(String, 'validate_string', $agent5_repo_uri)
  validate_legacy(String, 'validate_string', $agent6_repo_uri)
  validate_legacy(String, 'validate_string', $apt_release)
  validate_legacy(Integer, 'validate_integer', $cmd_port)

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

  if $use_apt_backup_keyserver {
    $_apt_keyserver = $apt_backup_keyserver
  } else {
    $_apt_keyserver = $apt_keyserver
  }

  case $::operatingsystem {
    'Ubuntu','Debian' : {
      if $agent5_enable {
        class { 'datadog_agent::ubuntu::agent5':
          agent_version         => $agent_version,
          service_ensure        => $service_ensure,
          service_enable        => $service_enable,
          service_provider      => $service_provider,
          location              => $agent5_repo_uri,
          release               => $apt_release,
          skip_apt_key_trusting => $skip_apt_key_trusting,
          apt_keyserver         => $_apt_keyserver,
        }
      } else {
        class { 'datadog_agent::ubuntu::agent6':
          agent_version         => $agent_version,
          service_ensure        => $service_ensure,
          service_enable        => $service_enable,
          service_provider      => $service_provider,
          location              => $agent6_repo_uri,
          release               => $apt_release,
          skip_apt_key_trusting => $skip_apt_key_trusting,
          apt_keyserver         => $_apt_keyserver,
        }
      }
    }
    'RedHat','CentOS','Fedora','Amazon','Scientific' : {
      if $agent5_enable {
        class { 'datadog_agent::redhat::agent5':
          baseurl          => $agent5_repo_uri,
          manage_repo      => $manage_repo,
          agent_version    => $agent_version,
          service_ensure   => $service_ensure,
          service_enable   => $service_enable,
          service_provider => $service_provider,
        }
      } else {
        class { 'datadog_agent::redhat::agent6':
          baseurl          => $agent6_repo_uri,
          manage_repo      => $manage_repo,
          agent_version    => $agent_version,
          service_ensure   => $service_ensure,
          service_enable   => $service_enable,
          service_provider => $service_provider,
        }
      }
    }
    default: { fail("Class[datadog_agent]: Unsupported operatingsystem: ${::operatingsystem}") }
  }

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
    mode    => '0755',
    require => Package[$datadog_agent::params::package_name],
  }

  if $agent5_enable {

    file { '/etc/dd-agent':
      ensure  => directory,
      owner   => $dd_user,
      group   => $dd_group,
      mode    => '0755',
      require => Package[$datadog_agent::params::package_name],
    }

    file { $conf_dir:
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

    if ($apm_enabled == true) and ($apm_env != 'none') or $apm_analyzed_spans {
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
  } else {
    # notify of broken params on agent6
    if !empty($proxy_host) {
        notify { 'Setting proxy_host will have no effect on agent6 please use agent6_extra_options to set your proxy': }
    }
    if !empty($proxy_port) {
        notify { 'Setting proxy_port will have no effect on agent6 please use agent6_extra_options to set your proxy': }
    }
    if !empty($proxy_user) {
        notify { 'Setting proxy_user will have no effect on agent6 please use agent6_extra_options to set your proxy': }
    }
    if !empty($proxy_password) {
        notify { 'Setting proxy_password will have no effect on agent6 please use agent6_extra_options to set your proxy': }
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
        'logs_config' => {
          'container_collect_all' => $container_collect_all,
        },
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
    $extra_config = deep_merge(
            $base_extra_config,
            $agent6_extra_options,
            $apm_analyzed_span_config,
            $statsd_forward_config,
            $host_config)

    file { $conf6_dir:
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
      'conf_path' => $datadog_agent::params::conf6_dir,
      'enable_metadata_collection' => $collect_instance_metadata,
      'dogstatsd_port' => $dogstatsd_port,
      'dogstatsd_socket' => $dogstatsd_socket,
      'dogstatsd_non_local_traffic' => $non_local_traffic,
      'log_file' => $agent6_log_file,
      'log_level' => $log_level,
      'tags' => unique(flatten(union($_local_tags, $_facts_tags))),
      'additional_checksd' => $additional_checksd,
    }

    $agent_config = deep_merge($_agent_config, $extra_config)

    file { '/etc/datadog-agent/datadog.yaml':
      owner   => 'dd-agent',
      group   => 'dd-agent',
      mode    => '0640',
      content => template('datadog_agent/datadog6.yaml.erb'),
      notify  => Service[$datadog_agent::params::service_name],
      require => File['/etc/datadog-agent'],
    }
  }


  if $puppet_run_reports {
    class { 'datadog_agent::reports':
      api_key                   => $api_key,
      datadog_site              => $datadog_site,
      puppet_gem_provider       => $puppet_gem_provider,
      dogapi_version            => $datadog_agent::params::dogapi_version,
      puppetmaster_user         => $puppetmaster_user,
      hostname_extraction_regex => $hostname_extraction_regex,
    }
  }

  create_resources('datadog_agent::integration', $local_integrations)
}
