node default {

  class { 'datadog_agent::integrations::apache':
    url      => 'http://example.com/server-status?auto',
    username => 'status',
    password => 'hunter1',
  }

}
