require 'spec_helper'

describe 'datadog_agent::integrations::fluentd' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/fluentd.yaml'
                  else
                    "#{CONF_DIR}/fluentd.d/conf.yaml"
                  end

      context 'with default parameters' do
        it { is_expected.to compile }
      end

      context 'with monitor_agent_url set' do
        let(:params) do
          {
            monitor_agent_url: 'foobar',
          }
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

        it { is_expected.to contain_file(conf_file).with_content(%r{monitor_agent_url: foobar}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{tags: }) }

        context 'with plugin_ids parameter array' do
          let(:params) do
            {
              monitor_agent_url: 'foobar',
              plugin_ids: ['foo', 'bar', 'baz'],
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{plugin_ids:[^-]+- foo\s+- bar\s+- baz\s*?[^-]}m) }
        end

        context 'plugin_ids not array' do
          let(:params) do
            {
              monitor_agent_url: 'foobar',
              plugin_ids: 'aoeu',
            }
          end

          it { is_expected.not_to compile }
        end
      end
    end
  end
end
