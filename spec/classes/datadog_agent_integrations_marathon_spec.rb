require 'spec_helper'

describe 'datadog_agent::integrations::marathon' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/marathon.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/marathon.d/conf.yaml" }
      end

      it { should compile.with_all_deps }
      it { should contain_file(conf_file).with(
        owner: DD_USER,
        group: DD_GROUP,
        mode: PERMISSIONS_FILE,
      )}
      it { should contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with default parameters' do
        it { should contain_file(conf_file).with_content(%r{default_timeout: 5}) }
        it { should contain_file(conf_file).with_content(%r{url: http://localhost:8080}) }
      end

      context 'with params set' do
        let(:params) {{
          marathon_timeout: 867,
          url: 'http://foo.bar.baz:5309',
        }}

        it { should contain_file(conf_file).with_content(%r{default_timeout: 867}) }
        it { should contain_file(conf_file).with_content(%r{url: http://foo.bar.baz:5309}) }
      end
    end
  end
end
