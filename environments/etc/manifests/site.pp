node default {

  class { 'datadog_agent':
    api_key             => 'somenonnullapikeythats32charlong',
    agent_extra_options => {
        use_http => true,
    },
    # Hostname is necessary for Agent to start up properly in container since 7.40.0
    # https://github.com/DataDog/datadog-agent/issues/14152#issuecomment-1301842615
    host                => 'some.dd.host',
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
