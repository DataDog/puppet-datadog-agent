# Class: datadog_agent::integrations::http_check
#
# This class will install the necessary config to hook the http_check in the agent
#
# Parameters:
#   url
#   timeout
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
#   include_content
#       The (optional) collect_response_time parameter will instruct the
#       check to create a metric 'network.http.response_time', tagged with
#       the url, reporting the response time in seconds.
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
#
# Sample Usage:
#
# class { 'datadog_agent::integrations::http_check':
#   url     => 'http://www.google.com/',
# }
#
# class { 'datadog_agent::integrations::http_check':
#   url     => 'http://localhost/',
#   headers => ['Host: stan.borbat.com', 'DNT: true'],
#   tags    => ['production', 'wordpress'],
# }
#
# class { 'datadog_agent::integrations::http_check':
#   url                   => 'http://localhost:9001/',
#   timeout               => 5,
#   threshold             => 1,
#   window                => 1,
#   include_content       => true,
#   collect_response_time => true,
#   contact               => 'pagerduty',
#   tags                  => 'production',
# }
#
#
class datadog_agent::integrations::http_check (
  $url       = undef,
  $username  = undef,
  $password  = undef,
  $timeout   = 1,
  $threshold = undef,
  $window    = undef,
  $include_content = false,
  $collect_response_time = true,
  $disable_ssl_validation = false,
  $headers   = [],
  $tags      = [],
  $contact   = [],
  $instances  = undef,
) inherits datadog_agent::params {
  include datadog_agent

  if !$instances and $url {
    $_instances = [{
      'url'                      => $url,
      'username'                 => $username,
      'password'                 => $password,
      'timeout'                  => $timeout,
      'threshold'                => $threshold,
      'window'                   => $window,
      'include_content'          => $include_content,
      'collect_response_time'    => $collect_response_time,
      'disable_ssl_validation' => $disable_ssl_validation,
      'headers'                  => $headers,
      'tags'                     => $tags,
      'contact'                  => $contact,
    }]
  } elsif !$instances{
    $_instances = []
  } else {
    $_instances = $instances
  }

  file { "${datadog_agent::params::conf_dir}/http_check.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/http_check.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
