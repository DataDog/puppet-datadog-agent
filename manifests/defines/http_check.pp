# Class: datadog::check::http
#
# This define contains a datadog http health check
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
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# datadog::check::http { 'Google Check': 
#   url     => 'http://www.google.com/',
# }
#
# datadog::check::http { 'Blog HTTP Check': 
#   url     => 'http://localhost/',
#   headers => ['Host: stan.borbat.com', 'DNT: 1'],
#   tags    => ['production', 'wordpress'],
# }
#
# datadog::check::http { 'Some Service Check':
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
define datadog::check::http (
  $url       = undef,
  $username  = undef,
  $password  = undef,
  $timeout   = 1,
  $threshold = undef,
  $window    = undef,
  $include_content = false,
  $collect_response_time = true,
  $headers   = [],
  $tags      = [],
  $contact   = [],
) {

  $http_check_yaml_file = '/etc/dd-agent/conf.d/http_check.yaml'

  if ( !defined( Concat[$http_check_yaml_file] ) ) {
    concat { $http_check_yaml_file:
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      notify => Service['datadog-agent'],
    }
  }

  if ( !defined( Concat::Fragment["datadog_http_check_header"] ) ) {
    concat::fragment { "datadog_http_check_header":
      target  => $http_check_yaml_file,
      content => "init_config:\n\ninstances:\n\n",
      order   => 10,
    }
  }

  concat::fragment { "datadog_http_check_fragment_$title":
    target  => $http_check_yaml_file,
    content => template('datadog/http_check.yaml.erb'),
    order   => 20,
  }

}
