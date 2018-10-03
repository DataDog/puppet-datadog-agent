# Test setup

This is an example setup, based on vagrant + virtualbox, that allows to easily run puppet commands to test the module.

# Requirements

- vagrant > 2.0.0
- virtualbox > 5.1.28

# Setup

in `puppet-datadog-agent/tests`:

- provision VM: `vagrant up`
- connect to the VM to check the configuration: `vagrant ssh`
- destroy VM when needed: `vagrant destroy -f`

## Module installation

- The default `Puppetfile` installs the latest released version of the module from Puppetforge.
- To use your development branch instead edit the Puppetfile et replace the `datadog-datadog_agent` with:
```
mod 'datadog-datadog_agent',
  :git    => 'https://github.com/DataDog/puppet-datadog-agent',
    :branch => '<my_branch>'
```

- We can also build the module locally using the `puppet build` command, upload the archive to the VM and install it with `puppet module install datadog-datadog_agent-x.y.z.tar.gz --target-dir /home/vagrant/puppet/modules`


## Manifest

The default manifest is `tests/environment/manifests/site.pp` and simply run the module with the default options.
We can edit the manifest and run `vagrant up --provision` to upload the new version to the VM.

# Test

In the VM, run `sudo /opt/puppetlabs/bin/puppet apply --modulepath=./modules ./manifests/site.pp` in `/home/vagrant` to apply to manifest on the VM.
