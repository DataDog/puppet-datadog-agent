require 'spec_helper'

describe 'datadog_agent::integrations::nginx' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/nginx.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/nginx.d/conf.yaml" }
      end

      it { should compile.with_all_deps }
      it { should contain_file(conf_file).with(
        owner: DD_USER,
        group: DD_GROUP,
        mode: PERMISSIONS_PROTECTED_FILE,
      )}
      it { should contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'default parameters' do
        it { should contain_file(conf_file).without_content(/^[^#]*nginx_status_url/) }
      end

      context 'parameters set' do
        let(:params) {{
          instances: [
            {
              'nginx_status_url' => 'http://foo.bar:1941/check',
              'tags' => %w{foo bar baz}
            }
          ],
          logs: [
            {
              'type' => 'file',
              'path' => '/var/log/nginx/access.log',
              'service' => 'nginx',
              'source' => 'nginx',
              'sourcecategory' => 'http_web_access'
            },
            {
              'type' => 'file',
              'path' => '/var/log/nginx/error.log',
              'service' => 'nginx',
              'source' => 'nginx',
              'sourcecategory' => 'http_web_access'
            }
          ]
        }}

        it { should contain_file(conf_file).with_content(%r{nginx_status_url:.*http://foo.bar:1941/check}m) }
        it { should contain_file(conf_file).with_content(%r{tags:.*foo.*bar.*baz}m) }
        it { should contain_file(conf_file).with_content(%r{type:.*file}m) }
        it { should contain_file(conf_file).with_content(%r{path:.*/var/log/nginx/access.log}m) }
        it { should contain_file(conf_file).with_content(%r{service:.*nginx}m) }
        it { should contain_file(conf_file).with_content(%r{source:.*nginx}m) }
        it { should contain_file(conf_file).with_content(%r{sourcecategory:.*http_web_access}m) }
        it { should contain_file(conf_file).with_content(%r{path:.*/var/log/nginx/error.log}m) }
      end
    end
  end
end
