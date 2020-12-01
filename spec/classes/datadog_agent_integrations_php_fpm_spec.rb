require 'spec_helper'

describe 'datadog_agent::integrations::php_fpm' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/php_fpm.yaml'
                  else
                    "#{CONF_DIR}/php_fpm.d/conf.yaml"
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
        it { is_expected.to contain_file(conf_file).with_content(%r{status_url: http://localhost/status}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{ping_url: http://localhost/ping}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{ping_reply: pong}) }
      end

      context 'with parameters set' do
        let(:params) do
          {
            status_url: 'http://localhost/fpm_status',
            ping_url: 'http://localhost/fpm_ping',
            ping_reply: 'success',
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{status_url: http://localhost/fpm_status}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{ping_url: http://localhost/fpm_ping}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{ping_reply: success}) }
      end

      context 'with http_host set' do
        let(:params) do
          {
            status_url: 'http://localhost/fpm_status',
            ping_url: 'http://localhost/fpm_ping',
            ping_reply: 'success',
            http_host: 'php_fpm_server',
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{http_host: php_fpm_server}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{status_url: http://localhost/fpm_status}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{ping_reply: success}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{ping_url: http://localhost/fpm_ping}) }
      end

      context 'with instances set' do
        let(:params) do
          {
            instances: [
              {
                'status_url' => 'http://localhost/a/fpm_status',
                'ping_url' => 'http://localhost/a/fpm_ping',
              },
              {
                'status_url' => 'http://localhost/b/fpm_status',
                'ping_url'   => 'http://localhost/b/fpm_ping',
                'ping_reply' => 'success',
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{status_url: http://localhost/a/fpm_status}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{ping_url: http://localhost/a/fpm_ping}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{ping_reply: pong}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{status_url: http://localhost/b/fpm_status}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{ping_url: http://localhost/b/fpm_ping}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{ping_reply: success}) }
      end
    end
  end
end
