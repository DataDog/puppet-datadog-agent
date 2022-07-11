# For testing if variable is empty
function datadog_agent::is_empty (
  Any $var
) {
  if $var.is_a(Collection) or $var.is_a(String) or $var.is_a(Numeric) or $var.is_a(Binary) or $var.is_a(Undef) {
    $var.empty
  } else {
    false
  }
}