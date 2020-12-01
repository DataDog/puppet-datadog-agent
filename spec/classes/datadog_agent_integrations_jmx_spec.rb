require 'spec_helper'

describe 'datadog_agent::integrations::jmx' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/jmx.yaml'
                  else
                    "#{CONF_DIR}/jmx.d/conf.yaml"
                  end

      it { is_expected.to compile.with_all_deps }
      it {
        is_expected.to contain_file(conf_file).with(
          owner: DD_USER,
          group: DD_GROUP,
          mode: PERMISSIONS_PROTECTED_FILE,
        )
      }
      it { is_expected.to contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { is_expected.to contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with default parameters' do
        it { is_expected.to contain_file(conf_file).with_content(%r{init_config: \{\}}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{instances: \[\]}) }
      end

      context 'with parameters set' do
        let(:params) do
          {
            'init_config' => {
              'custom_jar_paths' => [
                '/path/to/custom/jarfile.jar',
                '/path/to/another/custom/jarfile2.jar',
              ],
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
                'baz' => 'bat',
              },
              'conf' =>  [{
                'include' => {
                  'domain' => 'my_domain',
                },
              }],
            }],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{- ["']?/path/to/custom/jarfile.jar["']?}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{- ["']?/path/to/another/custom/jarfile2.jar["']?}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{host: jmx1}) }

        # Stringification of integers.
        # Puppet treats everything as a string, and then there seems to be
        # quoting differences between YAML export deps for Puppet 3.x and Puppet 4.x.
        # YAML defaults to string representation, but supports other types, so ends
        # up quoting integers from Puppet to explicitly mark out they're strings.
        it { is_expected.to contain_file(conf_file).with_content(%r{port: ["']?867["']?}) }

        it { is_expected.to contain_file(conf_file).with_content(%r{jmx_url: ["']?service:jmx:rmi:///jndi/rmi://myhost.host:9999/custompath["']?}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{user: userfoo}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{password: passbar}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{java_bin_path: ["']?/usr/java/jdk1.7.0_101/bin/java["']?}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{java_options: ["']?-Xmx200m -Xms50m["']?}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{trust_store_path: ["']?/var/lib/jmx/trust_store_path["']?}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{trust_store_password: hunter2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+foo: bar\s+baz: bat}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{domain: my_domain}) }
      end
    end
  end
end
