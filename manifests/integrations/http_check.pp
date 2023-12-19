# Class: datadog_agent::integrations::http_check
#
# This class will install the necessary config to hook the http_check in the agent
#
# Parameters:
#   @param sitename
#       (Required) The name of the instance.
#
#   @param url
#       (Required) The url to check.
#
#   @param timeout
#       The (optional) timeout in seconds.
#
#   @param method
#    	The (optional) HTTP method. This setting defaults to GET, though many
#    	other HTTP methods are supported, including POST and PUT.
#   @param min_collection_interval
#    	The (optional) collection interval of the check.
#    	default: 15
#       https://docs.datadoghq.com/developers/write_agent_check/#collection-interval
#   @param data
#       The (optional) data option. Data should be a string or an array of
#       'key: value' pairs and will be sent in the body of the request.
#
#   @param username
#   @param password
#       If your service uses basic authentication, you can optionally
#       specify a username and password that will be used in the check.
#
#   @param threshold
#   @param window
#       The (optional) window and threshold parameters allow you to trigger
#       alerts only if the check fails x times within the last y attempts
#       where x is the threshold and y is the window.
#
#   @param reverse_content_match
#       When (optional) true, reverses the behavior of the content_match option,
#       i.e. the HTTP check will report as DOWN if the string or expression
#       in content_match IS found. (default is false)
#
#   @param content_match
#       The (optional) content_match parameter will allow the check
#       to look for a particular string within the response. The check
#       will report as DOWN if the string is not found.
#       content_match uses Python regular expressions which means that
#       you will have to escape the following "special" characters with
#       a backslash (\) if you're trying to match them in your content:
#        . ^ $ * + ? { } [ ] \ | ( )
#
#   @param include_content
#       When (optional) true, includes the first 200 characters of the HTTP
#       response body in notifications. (default is false)
#
#   @param http_response_status_code
#       The (optional) http_response_status_code parameter will instruct the check
#       to look for a particular HTTP response status code or a Regex identifying
#       a set of possible status codes.
#       The check will report as DOWN if status code returned differs.
#       This defaults to 1xx, 2xx and 3xx HTTP status code: (1|2|3)\d\d.
#
#   @param collect_response_time
#       The (optional) collect_response_time parameter will instruct the
#       check to create a metric 'network.http.response_time', tagged with
#       the url, reporting the response time in seconds.
#
#   @param ca_certs
#       An optional string representing the path to CA certificates.
#
#   @param disable_ssl_validation
#       The setting disable_ssl_validation parameter to true will instruct
#       the http client to accept self signed, expired and otherwise
#       problematic SSL server certificates. To maintain backwards
#       compatibility this defaults to false.
#
#   @param ignore_ssl_warning
#       When SSL certificate validation is enabled (see setting above), this
#       setting will allow you to disable security warnings.
#
#   @param skip_event
#       The (optional) skip_event parameter will instruct the check to not
#       create any event to avoid duplicates with a server side service check.
#       This defaults to True because this is being deprecated.
#       (See https://github.com/DataDog/dd-agent/blob/master/checks/network_checks.py#L178-L180)
#
#   @param no_proxy
#       The (optional) no_proxy parameter would bypass any proxy settings enabled
#       and attempt to reach the the URL directly.
#       If no proxy is defined at any level, this flag bears no effect.
#       Defaults to False.
#
#   @param check_certificate_expiration
#   @param days_warning
#   @param days_critical
#       The (optional) check_certificate_expiration will instruct the check
#       to create a service check that checks the expiration of the
#       ssl certificate. Allow for a warning to occur when x days are
#       left in the certificate, and alternatively raise a critical
#       warning if the certificate is y days from the expiration date.
#       The SSL certificate will always be validated for this additional
#       service check regardless of the value of disable_ssl_validation
#
#   @param headers
#       The (optional) headers parameter allows you to send extra headers with
#       the request. Specify them like 'header-name: content'. This is useful for
#       explicitly specifying the 'host' header or for authorisation purposes.
#       Note that the http client library converts all headers to lowercase.
#       This is legal according to RFC2616
#       (See: http://tools.ietf.org/html/rfc2616#section-4.2)
#       but may be problematic with some HTTP servers
#       (See: https://code.google.com/p/httplib2/issues/detail?id=169)
#
#   @param allow_redirects
#       The (optional) allow_redirects parameter can enable redirection.
#       Defaults to True.
#
#   @param contact
#       For service-specific notifications, you can optionally specify
#       a list of users to notify within the service configuration.
#
#   @param tags
#       The (optional) tags to add to the check instance.
#
#   @param check_hostname
#
#   @param ssl_server_name
#
#   @param instances
#
#
# Sample Usage:
#
# Add a class for each check instance:
#
# class { 'datadog_agent::integrations::http_check':
#   sitename  => 'google',
#   url       => 'http://www.google.com/',
# }
#
# class { 'datadog_agent::integrations::http_check':
#   sitename => 'local',
#   url      => 'http://localhost/',
#   headers  => ['Host: stan.borbat.com', 'DNT: true'],
#   tags     => ['production', 'wordpress'],
# }
#
# class { 'datadog_agent::integrations::http_check':
#   sitename              => 'localhost-9001',
#   url                   => 'http://localhost:9001/',
#   timeout               => 5,
#   threshold             => 1,
#   window                => 1,
#   content_match         => '^(Bread|Apples) float(s)? in water'
#   include_content       => true,
#   collect_response_time => true,
#   contact               => 'pagerduty',
#   tags                  => 'production',
# }
#
#
# Add multiple instances in one class declaration:
#
#  class { 'datadog_agent::integrations::http_check':
#        instances => [{
#          'sitename'  => 'google',
#          'url'       => 'http://www.google.com',
#        },
#        {
#          'sitename' => 'local',
#          'url'      => 'http://localhost/',
#          'headers'  => ['Host: stan.borbat.com', 'DNT: true'],
#          'tags'     => ['production', 'wordpress']
#        }]
#     }

class datadog_agent::integrations::http_check (
  Optional[String] $sitename                  = undef,
  Optional[String] $url                       = undef,
  Optional[String] $username                  = undef,
  Optional[String] $password                  = undef,
  Integer $timeout                            = 1,
  String $method                              = 'get',
  Optional[Integer] $min_collection_interval  = undef,
  Optional[Variant[String, Array]] $data      = undef,
  Optional[String] $threshold                 = undef,
  Optional[String] $window                    = undef,
  Optional[Boolean] $content_match            = undef,
  Boolean $reverse_content_match              = false,
  Boolean $include_content                    = false,
  Optional[String] $http_response_status_code = undef,
  Boolean $collect_response_time              = true,
  Boolean $disable_ssl_validation             = false,
  Boolean $ignore_ssl_warning                 = false,
  Boolean $skip_event                         = true,
  Boolean $no_proxy                           = false,
  Boolean $check_certificate_expiration       = true,
  Optional[String] $days_warning              = undef,
  Optional[String] $days_critical             = undef,
  Optional[Boolean] $check_hostname           = undef,
  Optional[String] $ssl_server_name           = undef,
  Array $headers                              = [],
  Boolean $allow_redirects                    = true,
  Array $tags                                 = [],
  Array $contact                              = [],
  Optional[Array] $instances                  = undef,
  Optional[String] $ca_certs                  = undef,
) inherits datadog_agent::params {
  require datadog_agent

  if !$instances and $url {
    $_instances = [{
        'sitename'                     => $sitename,
        'url'                          => $url,
        'username'                     => $username,
        'password'                     => $password,
        'timeout'                      => $timeout,
        'method'                       => $method,
        'min_collection_interval'      => $min_collection_interval,
        'data'                         => $data,
        'threshold'                    => $threshold,
        'window'                       => $window,
        'content_match'                => $content_match,
        'reverse_content_match'        => $reverse_content_match,
        'include_content'              => $include_content,
        'http_response_status_code'    => $http_response_status_code,
        'collect_response_time'        => $collect_response_time,
        'disable_ssl_validation'       => $disable_ssl_validation,
        'ignore_ssl_warning'           => $ignore_ssl_warning,
        'skip_event'                   => $skip_event,
        'no_proxy'                     => $no_proxy,
        'check_certificate_expiration' => $check_certificate_expiration,
        'days_warning'                 => $days_warning,
        'days_critical'                => $days_critical,
        'check_hostname'               => $check_hostname,
        'ssl_server_name'              => $ssl_server_name,
        'headers'                      => $headers,
        'allow_redirects'              => $allow_redirects,
        'tags'                         => $tags,
        'contact'                      => $contact,
        'ca_certs'                     => $ca_certs,
    }]
  } elsif !$instances {
    $_instances = []
  } else {
    $_instances = $instances
  }

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/http_check.yaml"
  if versioncmp($datadog_agent::_agent_major_version, '5') > 0 {
    $dst_dir = "${datadog_agent::params::conf_dir}/http_check.d"
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
    content => template('datadog_agent/agent-conf.d/http_check.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
