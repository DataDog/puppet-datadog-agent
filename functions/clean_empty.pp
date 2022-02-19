# For cleaning up empty elements on hashes and arrays
function datadog_agent::clean_empty (
  Any $var
) {
  if $var.is_a(Array) {
    $_var = $var.map |$item| { datadog_agent::clean_empty($item) }
    $_var.filter |$item| { !$item.empty }

  } elsif $var.is_a(Hash) {
    $_var = Hash($var.map |$key, $value| { Tuple([$key, datadog_agent::clean_empty($value)]) })
    $_var.filter |$key, $value| { !$value.empty }

  } elsif !$var.empty {
    $var
  }
}
