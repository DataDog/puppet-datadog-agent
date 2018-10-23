# Allow custom tags via a define
define datadog_agent::tag(
  $tag_name = $name,
  $lookup_fact = false,
){

  $local_config_dir = '/etc/dd-agent/datadog.conf'
  if $lookup_fact{
    $value = getvar($tag_name)

    if is_array($value){
      $tags = prefix($value, "${tag_name}:")
      datadog_agent::tag{$tags: }
    } else {
      if $value {
        concat::fragment{ "datadog tag ${tag_name}:${value}":
          target  => "${local_config_dir}",
          content => "${tag_name}:${value}, ",
          order   => '03',
        }
      }
    }
  } else {
    concat::fragment{ "datadog tag ${tag_name}":
      target  => "${local_config_dir}",
      content => "${tag_name}, ",
      order   => '03',
    }
  }

}
