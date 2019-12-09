require 'spec_helper'

describe 'datadog_agent::integrations::cassandra' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |agent_major_version|
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }
      if agent_major_version == 5
        let(:conf_file) { "/etc/dd-agent/conf.d/cassandra.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR}/cassandra.d/conf.yaml" }
      end

      it { should compile.with_all_deps }
      it { should contain_class('datadog_agent') }

      context 'with password set' do
        let(:params) {{
          user: 'datadog',
          password: 'foobar',
        }}

        it { should contain_file(conf_file).with(
          owner: DD_USER,
          group: DD_GROUP,
          mode: PERMISSIONS_PROTECTED_FILE,
        )}
        it { should contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
        it { should contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

        it { should contain_file(conf_file).with_content(%r{password: foobar}) }
        it { should contain_file(conf_file).without_content(%r{tags: }) }

        context 'with defaults' do
          it { should contain_file(conf_file).with_content(%r{host: localhost}) }
          it { should contain_file(conf_file).with_content(%r{user: datadog}) }
        end

        context 'with parameters set' do
          let(:params) {{
            password: 'foobar',
            host: 'cassandra1',
            user: 'baz',
          }}

          it { should contain_file(conf_file).with_content(%r{password: foobar}) }
          it { should contain_file(conf_file).with_content(%r{host: cassandra1}) }
          it { should contain_file(conf_file).with_content(%r{user: baz}) }
        end

        context 'with tags parameter hash' do
          let(:params) {{
            password: 'foobar',
            tags: {
                    'foo'=> 'bar',
                    'baz'=> 'ama',
            }
          }}
          it { should contain_file(conf_file).with_content(/tags:\s+foo: bar\s+baz: ama\s*?[^-]/m) }
        end

        context 'tags not hash' do
          let(:params) {{
            password: 'foobar',
            tags: 'aoeu',
          }}

          it { should_not compile }
        end
      end
    end
  end
end
