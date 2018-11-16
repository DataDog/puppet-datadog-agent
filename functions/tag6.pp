# For compatibility with puppet 4.6 return type is left
# out of the function signature, but `tag6` should return
# an Array

function datadog_agent::tag6(
  Variant[Array, String] $tag_names,
  Variant[String, Boolean] $lookup_fact = false,
) {
  if $tag_names =~ Array {
    $tags = $tag_names.reduce([]) |$_tags , $tag| {
        concat($_tags, datadog_agent::tag6($tag, $lookup_fact))
    }
  } else {
    if $lookup_fact =~ String {
      $lookup = str2bool($lookup_fact)
    } else {
      $lookup = $lookup_fact
    }

    if $lookup {
      $value = getvar($tag_names)
      if $value =~ Array {
        $tags = prefix($value, "${tag_names}:")
      } else {
        $tags = ["${tag_names}:${value}"]
      }
    } else {
      $tags = [$tag_names]
    }
  }

  $tags
}
