require 'spec_helper'

describe 'datadog_agent::integrations::kong' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/kong.yaml'
                  else
                    "#{CONF_DIR}/kong.d/conf.yaml"
                  end

      it { is_expected.to compile.with_all_deps }
      it {
        is_expected.to contain_file(conf_file).with(
          owner: DD_USER,
          group: DD_GROUP,
          mode: PERMISSIONS_FILE,
        )
      }
      it { is_expected.to contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { is_expected.to contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with default parameters' do
        it { is_expected.to contain_file(conf_file).with_content(%r{kong_status_url: http://localhost:8001/status/}) }
      end

      context 'with params set' do
        let(:params) do
          {
            instances: [
              {
                'status_url' => 'http://foo.bar:8080/status/',
                'tags' => ['baz'],
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{tags:[\r\n]+.*- baz}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{kong_status_url: http://foo.bar:8080/status/}) }
      end
    end
  end
end
