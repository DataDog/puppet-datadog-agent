require 'spec_helper'

describe 'datadog_agent::integrations::php_fpm' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/php_fpm.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/php_fpm.d/conf.yaml" }
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
        it { should contain_file(conf_file).with_content(/status_url: http:\/\/localhost\/status/) }
        it { should contain_file(conf_file).with_content(/ping_url: http:\/\/localhost\/ping/) }
        it { should contain_file(conf_file).with_content(/ping_reply: pong/) }
      end

      context 'with parameters set' do
        let(:params) {{
          status_url: 'http://localhost/fpm_status',
          ping_url: 'http://localhost/fpm_ping',
          ping_reply: 'success',
        }}
        it { should contain_file(conf_file).with_content(/status_url: http:\/\/localhost\/fpm_status/) }
        it { should contain_file(conf_file).with_content(/ping_url: http:\/\/localhost\/fpm_ping/) }
        it { should contain_file(conf_file).with_content(/ping_reply: success/) }
      end

      context 'with http_host set' do
        let(:params) {{
          status_url: 'http://localhost/fpm_status',
          ping_url: 'http://localhost/fpm_ping',
          ping_reply: 'success',
          http_host: 'php_fpm_server',
        }}
        it { should contain_file(conf_file).with_content(/http_host: php_fpm_server/) }
        it { should contain_file(conf_file).with_content(/status_url: http:\/\/localhost\/fpm_status/) }
        it { should contain_file(conf_file).with_content(/ping_reply: success/) }
        it { should contain_file(conf_file).with_content(/ping_url: http:\/\/localhost\/fpm_ping/) }
      end

      context 'with instances set' do
        let(:params) {{
          instances: [
            {
              'status_url'   => 'http://localhost/a/fpm_status',
              'ping_url'   => 'http://localhost/a/fpm_ping',
            },
            {
              'status_url'   => 'http://localhost/b/fpm_status',
              'ping_url'   => 'http://localhost/b/fpm_ping',
              'ping_reply' => 'success',
            },
          ]
        }}
        it { should contain_file(conf_file).with_content(/status_url: http:\/\/localhost\/a\/fpm_status/) }
        it { should contain_file(conf_file).with_content(/ping_url: http:\/\/localhost\/a\/fpm_ping/) }
        it { should contain_file(conf_file).with_content(/ping_reply: pong/) }
        it { should contain_file(conf_file).with_content(/status_url: http:\/\/localhost\/b\/fpm_status/) }
        it { should contain_file(conf_file).with_content(/ping_url: http:\/\/localhost\/b\/fpm_ping/) }
        it { should contain_file(conf_file).with_content(/ping_reply: success/) }
      end
    end
  end
end
