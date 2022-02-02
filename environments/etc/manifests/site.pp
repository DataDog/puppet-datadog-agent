node default {

  class { 'datadog_agent':
    api_key             => 'somenonnullapikeythats32charlong',
    agent_extra_options => {
        use_http => true,
    },
    facts_to_tags       => ['osfamily'],
    integrations        => {
      'ntp' => {
        init_config => {},
        instances   => [{
            offset_threshold => 30,
        }],
      },
    },
  }

  class { 'datadog_agent::integrations::apache':
    url      => 'http://example.com/server-status?auto',
    username => 'status',
    password => 'hunter1',
  }

}
