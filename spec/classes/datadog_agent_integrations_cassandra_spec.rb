require 'spec_helper'

describe 'datadog_agent::integrations::cassandra' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/cassandra.yaml'
                  else
                    "#{CONF_DIR}/cassandra.d/conf.yaml"
                  end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('datadog_agent') }

      context 'with password set' do
        let(:params) do
          {
            user: 'datadog',
            password: 'foobar',
          }
        end

        it {
          is_expected.to contain_file(conf_file).with(
            owner: DD_USER,
            group: DD_GROUP,
            mode: PERMISSIONS_PROTECTED_FILE,
          )
        }
        it { is_expected.to contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
        it { is_expected.to contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

        it { is_expected.to contain_file(conf_file).with_content(%r{password: foobar}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{tags: }) }

        context 'with defaults' do
          it { is_expected.to contain_file(conf_file).with_content(%r{host: localhost}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{user: datadog}) }
        end

        context 'with parameters set' do
          let(:params) do
            {
              password: 'foobar',
              host: 'cassandra1',
              user: 'baz',
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{password: foobar}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{host: cassandra1}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{user: baz}) }
        end

        context 'with tags parameter hash' do
          let(:params) do
            {
              password: 'foobar',
              tags: {
                'foo' => 'bar',
                'baz' => 'ama',
              },
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+-\s+foo:bar\s+-\s+baz:ama\s*?[^-]}m) }
        end

        context 'tags not hash' do
          let(:params) do
            {
              password: 'foobar',
              tags: 'aoeu',
            }
          end

          it { is_expected.not_to compile }
        end
      end
    end
  end
end
