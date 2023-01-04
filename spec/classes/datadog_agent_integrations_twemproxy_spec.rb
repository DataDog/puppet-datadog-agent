require 'spec_helper'

describe 'datadog_agent::integrations::twemproxy' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/twemproxy.yaml'
                  else
                    "#{CONF_DIR}/twemproxy.d/conf.yaml"
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
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 22222}) }
      end

      context 'with parameters set' do
        let(:params) do
          {
            instances: [
              {
                'host' => 'twemproxy1',
                'port' => '1234',
              },
              {
                'host' => 'twemproxy2',
                'port' => '4567',
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{host: twemproxy1}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 1234}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{host: twemproxy2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 4567}) }
      end
    end
  end
end
