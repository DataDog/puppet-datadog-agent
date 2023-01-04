require 'spec_helper'

describe 'datadog_agent::integrations::tomcat' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/tomcat.yaml'
                  else
                    "#{CONF_DIR}/tomcat.d/conf.yaml"
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
        it { is_expected.to contain_file(conf_file).with_content(%r{host: localhost}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 7199}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{user: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{password: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{java_bin_path:}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{trust_store_path:}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{trust_store_password}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{tags:}) }
      end

      context 'with parameters set' do
        let(:params) do
          {
            hostname: 'tomcat1',
            port: 867,
            username: 'userfoo',
            password: 'passbar',
            java_bin_path: '/opt/bin/java',
            trust_store_path: '/var/lib/tomcat/trust_store_path',
            trust_store_password: 'hunter2',
            tags: {
              'foo' => 'bar',
              'baz' => 'bat',
            },
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{host: tomcat1}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 867}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{user: userfoo}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{password: passbar}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{java_bin_path: /opt/bin/java}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{trust_store_path: /var/lib/tomcat/trust_store_path}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{trust_store_password: hunter2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+foo: bar\s+baz: bat}) }
      end

      context 'with jmx_url parameter set' do
        let(:params) do
          {
            hostname: 'tomcat1',
            jmx_url: 'service:jmx:rmi:///jndi/rmi://tomcat.foo:9999/custompath',
            username: 'userfoo',
            password: 'passbar',
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{host: tomcat1}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{jmx_url: "service:jmx:rmi:///jndi/rmi://tomcat.foo:9999/custompath"}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{user: userfoo}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{password: passbar}) }
      end
    end
  end
end
