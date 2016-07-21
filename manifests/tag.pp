# Allow custom tags via a define
define datadog_agent::tag(
  $tag = $name,
  $lookup_fact = false,
){

  if $lookup_fact{
    $value = getvar($tag)

    if is_array($value){
      $tags = prefix($value, "${tag}:")
      datadog_agent::tag{$tags: }
    } else {
      if $value {
        concat::fragment{ "datadog tag ${tag}:${value}":
          target  => '/etc/dd-agent/datadog.conf',
          content => "${tag}:${value}, ",
          order   => '03',
        }
      }
    }
  } else {
    concat::fragment{ "datadog tag ${tag}":
      target  => '/etc/dd-agent/datadog.conf',
      content => "${tag}, ",
      order   => '03',
    }
  }

}
