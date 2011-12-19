puppet-datadog-agent
====================

Description
-----------

A module to install the DataDog agent.

Requirements
------------

* `puppet`

Installation
------------

Install `datadog` as a module in your Puppet master's module
path. Remember to rename the directory to `datadog` from
`puppet-datadog-agent`.

Usage
-----

1. Update the default class parameters with your API key (and confirm the
   DataDog URL is correct in datadog::params).

2. Specify the module on any nodes you wish to install the DataDog
   Agent.

        include datadog

  Or assign this module using the Puppet 2.6 style Parameterized class:
        class {'datadog':
          api_key => "yourkey",
        }

Author
------

James Turnbull <james@lovedthanlost.net>

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
