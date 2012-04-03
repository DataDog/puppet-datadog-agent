puppet-datadog-agent
====================

Description
-----------

A module to install the DataDog agent, and to send reports of puppet runs
to the Datadog service [Datadog](http://www.datadoghq.com/).

Requirements
------------

* `puppet`
* A Datadog account and API Key

On your Puppet master:

* `dogapi` gem (v 1.0.3 and later)
* `ruby-dev` headers, required to build dogapi gem

Installation
------------

Install `datadog` as a module in your Puppet master's module
path. Remember to rename the directory to `datadog` from
`puppet-datadog-agent`.

Usage
-----

1. Update the default class parameters with your [API key](https://app.datadoghq.com/account/settings#api)
   (and confirm the DataDog URL is correct in datadog::params).

2. Specify the module on any nodes you wish to install the DataDog
   Agent.

        include datadog

  Or assign this module using the Puppet 2.6 style Parameterized class:
        class { 'datadog':
          api_key => "yourkey",
        }

  On your Puppet master, enable reporting:

        class { 'datadog':
          api_key => "yourkey",
          puppet_run_reports = true,
        }

Reporting
-----
To enable reporting of changes to the Datadog timeline, enable the report 
processor on your Puppet master, and enable reporting for your clients. 
The clients will send a run report after each check-in back to the master, 
and the master will process the reports and send them to the Datadog API.


   In your Puppet master /etc/puppet/puppet.conf, add these config options:

        [master]
        ...
        reports="datadog_reports"

        [agent]
        ...
        pluginsync=true
        report=true


   And on all of your Puppet client nodes add:

        [agent]
        ...
        report=true


Authors
-------

* James Turnbull <james@lovedthanlost.net>
* Alexis Lê-Quôc <alq@datadoghq.com>
* Rob Terhaar <rob@atlanticdynamic.com>

License
-------

    Author:: James Turnbull (<james@lovedthanlost.net>)
    Copyright:: Copyright (c) 2011 James Turnbull
    License:: Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
