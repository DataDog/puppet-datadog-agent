# Class: datadog::integrations::http_check
#
# This class will install the necessary configuration for the http_check integration
#
# Parameters:
#   $notify_global:
#       Array of emails or pagerduty. See example
#   $http_checks:
#       Array of http_check hashes. See example and template for parameter explanation
#
# Sample Usage:
#
# class { 'datadog::integrations::http_check':
#     notify_global => [ 'user1@example.com', 'pagerduty' ],
#     http_checks   => [
#         {
#             'name'    => 'My first service',
#             'url'     => 'http://some.url.example.com',
#             'timeout' => 1,
#             'username'=> 'user',  # optional
#             'password'=> 'pass',  # optional
#             'threshold'   => 3,  # optional
#             'window'      => 5,  # optional
#             'include_content'         => false,  # optional
#             'collect_response_time'   => true,  # optional
#             'disable_ssl_validation'  => true,  # optional
#             'headers' => {'Host'=>'alternative.host.example.com', 'X-Auth-Token'=>'SOME-AUTH-TOKEN'},  # optional
#             'tags'    => ['env:staging', 'tag2'],  # optional
#             'notify'  => ['user1@example.com', 'pagerduty'],  # optional
#         },
#         {
#             'name'    => 'My second service',
#             'url'     => 'http://some.url.example.com',
#             'timeout' => 5,
#         },
#     ],
# }

#
#
class datadog::integrations::http_check(
  $notify_global = [],
  $http_checks = [],
) inherits datadog::params {

  validate_array( $notify_global )
  validate_array( $http_checks )

  file { "${conf_dir}/http_check.yaml":
    ensure  => file,
    owner   => $datadog::dd_user,
    group   => $datadog::dd_group,
    mode    => 0600,
    content => template('datadog/agent-conf.d/http_check.yaml.erb'),
    notify  => Service[$service_name]
  }
}
