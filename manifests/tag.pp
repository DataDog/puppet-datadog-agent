# Allow custom tags via a define
define datadog_agent::tag(
  $tag = $name,
){
  concat::fragment{ "datadog tag ${tag}":
    target  => '/etc/dd-agent/datadog.conf',
    content => "${tag}, ",
    order   => '03',
  }
}
