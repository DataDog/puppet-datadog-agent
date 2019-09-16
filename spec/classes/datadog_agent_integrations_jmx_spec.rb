require 'spec_helper'

describe 'datadog_agent::integrations::jmx' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/jmx.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/jmx.d/conf.yaml" }
      end

      it { should compile.with_all_deps }
      it { should contain_file(conf_file).with(
        owner: DD_USER,
        group: DD_GROUP,
        mode: PERMISSIONS_PROTECTED_FILE,
      )}
      it { should contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with default parameters' do
        it { should contain_file(conf_file).with_content(%r{init_config: \{\}}) }
        it { should contain_file(conf_file).with_content(%r{instances: \[\]}) }
      end

      context 'with parameters set' do
        let(:params) do
          {
            'init_config' => {
              'custom_jar_paths' => [
               '/path/to/custom/jarfile.jar',
               '/path/to/another/custom/jarfile2.jar'
              ]
            },
            'instances' => [{
              'host' => 'jmx1',
              'port' => '867',
              'user' => 'userfoo',
              'password' => 'passbar',
              'jmx_url' => 'service:jmx:rmi:///jndi/rmi://myhost.host:9999/custompath',
              'tools_jar_path' => '/usr/lib/jvm/java-7-openjdk-amd64/lib/tools.jar',
              'java_options' => '-Xmx200m -Xms50m',
              'java_bin_path' => '/usr/java/jdk1.7.0_101/bin/java',
              'trust_store_path' => '/var/lib/jmx/trust_store_path',
              'trust_store_password' => 'hunter2',
              'tags' => {
                'foo' => 'bar',
                'baz' => 'bat'
              },
              'conf' =>  [{
                'include' => {
                  'domain' => 'my_domain'
                }
              }]
            }]
          }
        end
        it { should contain_file(conf_file).with_content(%r{- ["']?/path/to/custom/jarfile.jar["']?}) }
        it { should contain_file(conf_file).with_content(%r{- ["']?/path/to/another/custom/jarfile2.jar["']?}) }
        it { should contain_file(conf_file).with_content(%r{host: jmx1}) }

        # Stringification of integers.
        # Puppet treats everything as a string, and then there seems to be
        # quoting differences between YAML export deps for Puppet 3.x and Puppet 4.x.
        # YAML defaults to string representation, but supports other types, so ends
        # up quoting integers from Puppet to explicitly mark out they're strings.
        it { should contain_file(conf_file).with_content(%r{port: ["']?867["']?}) }

        it { should contain_file(conf_file).with_content(%r{jmx_url: ["']?service:jmx:rmi:///jndi/rmi://myhost.host:9999/custompath["']?}) }
        it { should contain_file(conf_file).with_content(%r{user: userfoo}) }
        it { should contain_file(conf_file).with_content(%r{password: passbar}) }
        it { should contain_file(conf_file).with_content(%r{java_bin_path: ["']?/usr/java/jdk1.7.0_101/bin/java["']?}) }
        it { should contain_file(conf_file).with_content(%r{java_options: ["']?-Xmx200m -Xms50m["']?}) }
        it { should contain_file(conf_file).with_content(%r{trust_store_path: ["']?/var/lib/jmx/trust_store_path["']?}) }
        it { should contain_file(conf_file).with_content(%r{trust_store_password: hunter2}) }
        it { should contain_file(conf_file).with_content(%r{tags:\s+foo: bar\s+baz: bat}) }
        it { should contain_file(conf_file).with_content(%r{domain: my_domain}) }
      end
    end
  end
end
