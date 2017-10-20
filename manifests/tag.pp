# Allow custom tags via a define
define datadog_agent::tag(
  $tag_name = $name,
  $lookup_fact = false,
){

  if $lookup_fact{
    $value = getvar($tag_name)

    if is_array($value){
      $tags = prefix($value, "${tag_name}:")
      datadog_agent::tag{$tags: }
    } else {
      if $value {
        concat::fragment{ "datadog tag ${tag_name}:${value}":
          target  => '/etc/dd-agent/datadog.conf',
          content => "${tag_name}:${value}, ",
          order   => '03',
        }
      }
    }
  } else {
    concat::fragment{ "datadog tag ${tag_name}":
      target  => '/etc/dd-agent/datadog.conf',
      content => "${tag_name}, ",
      order   => '03',
    }
  }

}
