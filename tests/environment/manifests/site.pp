node "localhost" {
    class { "datadog_agent":
       api_key => "somenonnullapikeythats32charlong",
   }
}
