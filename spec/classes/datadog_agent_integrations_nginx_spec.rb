require 'spec_helper'

describe 'datadog_agent::integrations::nginx' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/nginx.yaml'
                  else
                    "#{CONF_DIR}/nginx.d/conf.yaml"
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

      context 'default parameters' do
        it { is_expected.to contain_file(conf_file).without_content(%r{^[^#]*nginx_status_url}) }
      end

      context 'parameters set' do
        let(:params) do
          {
            instances: [
              {
                'nginx_status_url' => 'http://foo.bar:1941/check',
                'tags' => ['foo', 'bar', 'baz'],
              },
            ],
            logs: [
              {
                'type' => 'file',
                'path' => '/var/log/nginx/access.log',
                'service' => 'nginx',
                'source' => 'nginx',
                'sourcecategory' => 'http_web_access',
              },
              {
                'type' => 'file',
                'path' => '/var/log/nginx/error.log',
                'service' => 'nginx',
                'source' => 'nginx',
                'sourcecategory' => 'http_web_access',
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{nginx_status_url:.*http://foo.bar:1941/check}m) }
        it { is_expected.to contain_file(conf_file).with_content(%r{tags:.*foo.*bar.*baz}m) }
        it { is_expected.to contain_file(conf_file).with_content(%r{type:.*file}m) }
        it { is_expected.to contain_file(conf_file).with_content(%r{path:.*/var/log/nginx/access.log}m) }
        it { is_expected.to contain_file(conf_file).with_content(%r{service:.*nginx}m) }
        it { is_expected.to contain_file(conf_file).with_content(%r{source:.*nginx}m) }
        it { is_expected.to contain_file(conf_file).with_content(%r{sourcecategory:.*http_web_access}m) }
        it { is_expected.to contain_file(conf_file).with_content(%r{path:.*/var/log/nginx/error.log}m) }
      end
    end
  end
end
