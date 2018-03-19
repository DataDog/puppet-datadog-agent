require 'spec_helper'

describe 'datadog_agent::integrations::php_fpm' do
  context 'supported agents - v5 and v6' do
    agents = { '5' => true, '6' => false }
    agents.each do |_, enabled|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{enabled}}" }
      let(:facts) {{
        operatingsystem: 'Ubuntu',
      }}
      if enabled
        let(:conf_dir) { '/etc/dd-agent/conf.d' }
      else
        let(:conf_dir) { '/etc/datadog-agent/conf.d' }
      end
      let(:dd_user) { 'dd-agent' }
      let(:dd_group) { 'root' }
      let(:dd_package) { 'datadog-agent' }
      let(:dd_service) { 'datadog-agent' }
      let(:conf_file) { "#{conf_dir}/php_fpm.yaml" }

      it { should compile.with_all_deps }
      it { should contain_file(conf_file).with(
        owner: dd_user,
        group: dd_group,
        mode: '0600',
      )}
      it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

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
