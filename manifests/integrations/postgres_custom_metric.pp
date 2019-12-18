##
# The postgres_custom_metric defines a custom sql metric.
# https://help.datadoghq.com/hc/en-us/articles/208385813-Postgres-custom-metric-collection-explained
#
# $query:
#   The custom metric SQL query. It must contain a '%s' for defining the metrics.
#
# $metrics:
#   a hash of column name to metric definition. a metric definition is an array
#   consisting of two columns -- the datadog metric name and the metric type.
#
# $relation:
#   ?
#
# $descriptor:
#   an array that maps an sql column's to a tag. Each descriptor consists of two
#   fields -- column name, and datadog tag.
define datadog_agent::integrations::postgres_custom_metric(
  String $query,
  Hash $metrics,
  Boolean $relation = false,
  Array $descriptors = [],
) {

  if $query !~ '^.*%s.*$' {
    fail('custom_metrics require %s for metric substitution')
  }
}
