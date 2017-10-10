# Class: datadog_agent::integrations::http_check
#
# This class will install the necessary config to hook the http_check in the agent
#
# Parameters:
#   sitename
#       (Required) The name of the instance.
#
#   url
#       (Required) The url to check.
#
#   timeout
#       The (optional) timeout in seconds.
#
#   username
#   password
#       If your service uses basic authentication, you can optionally
#       specify a username and password that will be used in the check.
#
#   threshold
#   window
#       The (optional) window and threshold parameters allow you to trigger
#       alerts only if the check fails x times within the last y attempts
#       where x is the threshold and y is the window.
#
#   content_match
#       The (optional) content_match parameter will allow the check
#       to look for a particular string within the response. The check
#       will report as DOWN if the string is not found.
#       content_match uses Python regular expressions which means that
#       you will have to escape the following "special" characters with
#       a backslash (\) if you're trying to match them in your content:
#        . ^ $ * + ? { } [ ] \ | ( )
#
#   include_content
#       The (optional) collect_response_time parameter will instruct the
#       check to create a metric 'network.http.response_time', tagged with
#       the url, reporting the response time in seconds.
#
#   http_response_status_code
#       The (optional) http_response_status_code parameter will instruct the check
#       to look for a particular HTTP response status code or a Regex identifying
#       a set of possible status codes.
#       The check will report as DOWN if status code returned differs.
#       This defaults to 1xx, 2xx and 3xx HTTP status code: (1|2|3)\d\d.
#
#   collect_response_time
#       The (optional) collect_response_time parameter will instruct the
#       check to create a metric 'network.http.response_time', tagged with
#       the url, reporting the response time in seconds.
#
#   disable_ssl_validation
#       The setting disable_ssl_validation parameter to true will instruct
#       the http client to accept self signed, expired and otherwise
#       problematic SSL server certificates. To maintain backwards
#       compatibility this defaults to false.
#
#   skip_event
#       The (optional) skip_event parameter will instruct the check to not
#       create any event to avoid duplicates with a server side service check.
#       This defaults to True because this is being deprecated.
#       (See https://github.com/DataDog/dd-agent/blob/master/checks/network_checks.py#L178-L180)
#
#   no_proxy
#       The (optional) no_proxy parameter would bypass any proxy settings enabled
#       and attempt to reach the the URL directly.
#       If no proxy is defined at any level, this flag bears no effect.
#       Defaults to False.
#
#   check_certificate_expiration
#   days_warning
#   days_critical
#       The (optional) check_certificate_expiration will instruct the check
#       to create a service check that checks the expiration of the
#       ssl certificate. Allow for a warning to occur when x days are
#       left in the certificate, and alternatively raise a critical
#       warning if the certificate is y days from the expiration date.
#       The SSL certificate will always be validated for this additional
#       service check regardless of the value of disable_ssl_validation
#
#   headers
#       The (optional) headers parameter allows you to send extra headers
#       with the request. This is useful for explicitly specifying the host
#       header or perhaps adding headers for authorisation purposes. Note
#       that the http client library converts all headers to lowercase.
#       This is legal according to RFC2616
#       (See: http://tools.ietf.org/html/rfc2616#section-4.2)
#       but may be problematic with some HTTP servers
#       (See: https://code.google.com/p/httplib2/issues/detail?id=169)
#
#   contact
#       For service-specific notifications, you can optionally specify
#       a list of users to notify within the service configuration.
#
#   tags
#       The (optional) tags to add to the check instance.
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
  $sitename  = undef,
  $url       = undef,
  $username  = undef,
  $password  = undef,
  $timeout   = 1,
  $threshold = undef,
  $window    = undef,
  $content_match = undef,
  $include_content = false,
  $http_response_status_code = undef,
  $collect_response_time = true,
  $disable_ssl_validation = false,
  $skip_event = true,
  $no_proxy  = false,
  $check_certificate_expiration = undef,
  $days_warning = undef,
  $days_critical = undef,
  $headers   = [],
  $tags      = [],
  $contact   = [],
  $instances  = undef,
) inherits datadog_agent::params {
  include datadog_agent

  if !$instances and $url {
    $_instances = [{
      'sitename'                     => $sitename,
      'url'                          => $url,
      'username'                     => $username,
      'password'                     => $password,
      'timeout'                      => $timeout,
      'threshold'                    => $threshold,
      'window'                       => $window,
      'content_match'                => $content_match,
      'include_content'              => $include_content,
      'http_response_status_code'    => $http_response_status_code,
      'collect_response_time'        => $collect_response_time,
      'disable_ssl_validation'       => $disable_ssl_validation,
      'skip_event'                   => $skip_event,
      'no_proxy'                     => $no_proxy,
      'check_certificate_expiration' => $check_certificate_expiration,
      'days_warning'                 => $days_warning,
      'days_critical'                => $days_critical,
      'headers'                      => $headers,
      'tags'                         => $tags,
      'contact'                      => $contact,
    }]
  } elsif !$instances{
    $_instances = []
  } else {
    $_instances = $instances
  }

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/http_check.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/http_check.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/http_check.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
