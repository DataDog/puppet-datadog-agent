# Contributing

[![Build Status](https://img.shields.io/circleci/build/gh/DataDog/puppet-datadog-agent.svg)](https://circleci.com/gh/DataDog/puppet-datadog-agent)
[![Puppet Forge](https://img.shields.io/puppetforge/v/datadog/datadog_agent.svg)](https://forge.puppetlabs.com/datadog/datadog_agent)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/datadog/datadog_agent.svg)](https://forge.puppetlabs.com/datadog/datadog_agent)

## Module development and testing

### Clone the repo

```
git clone git@github.com:DataDog/puppet-datadog-agent.git
cd puppet-datadog-agent
```

### Install dependencies

```
bundle install
rake lint              # Check Puppet manifests with puppet-lint / Run puppet-lint
rake spec              # Run spec tests in a clean fixtures directory
rake syntax            # Syntax check Puppet manifests and templates
rake syntax:manifests  # Syntax check Puppet manifests
rake syntax:templates  # Syntax check Puppet templates
pip install pre-commit
pre-commit install
```

### Manual testing

To test the roles provided by this project, you can follow the instructions in the manual tests [readme.md](./environments/README.md).

### Integration testing

This project uses [Kitchen](https://github.com/test-kitchen/test-kitchen) as its integration tests engine. To really verify integration tests, you should have [Vagrant](https://www.vagrantup.com/) installed on your machine as it is used as a driver-engine.

Kitchen allows you to test specific recipes described in [kitchen.yml](./.kitchen.yml). For now, there is only a basic one on Ubuntu, but that should be enough to develop others or to add features in TDD.

To list available targets, you can use the `list` command:

```bash
bundle exec kitchen list
```

To test a specific target, you can run:

```bash
bundle exec kitchen test <target>
```

So for example, if you want to test the Agent installation, you can run:

```bash
bundle exec kitchen test dd-agent-ubuntu1604
```

More information about kitchen on its [Getting Started](https://github.com/test-kitchen/test-kitchen/wiki/Getting-Started).

### Development loop

To develop fixes or features, work on the platform and version of your choice, setting the machine up with the `create` command and applying the recipe with the `converge` command. If you want to explore the machine and try different things, you can also log into the machine with the `login` command.

```bash
# Create the relevant vagrant virtual machine
bundle exec kitchen create dd-agent-ubuntu1604

# Converge to test your recipe
bundle exec kitchen converge dd-agent-ubuntu1604

# Login to your machine to check stuff
bundle exec kitchen login dd-agent-ubuntu1604

# Verify the integration tests for your machine
bundle exec kitchen verify dd-agent-ubuntu1604

# Clean your machine
bundle exec kitchen destroy dd-agent-ubuntu1604
```

It is advised that you work in TDD and that you write tests before making changes so that developing your feature or fix is just making tests pass.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
