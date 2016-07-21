# Allow custom tags via a define
define datadog_agent::tag(
  $tag = $name,
  $lookup_fact = false,
){
  unless $lookup_fact {
    concat::fragment{ "datadog tag ${tag}":
      target  => '/etc/dd-agent/datadog.conf',
      content => "${tag}, ",
      order   => '03',
    }
  } else {
    $value = getvar($tag)
    concat::fragment{ "datadog tag ${tag}":
      target  => '/etc/dd-agent/datadog.conf',
      content => "${tag}:${value}, ",
      order   => '03',
    }
  }
}
