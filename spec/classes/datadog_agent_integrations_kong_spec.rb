require 'spec_helper'

describe 'datadog_agent::integrations::kong' do
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
      if enabled
        let(:conf_file) { "#{conf_dir}/kong.yaml" }
      else
        let(:conf_file) { "#{conf_dir}/kong.d/conf.yaml" }
      end

      it { should compile.with_all_deps }
      it { should contain_file(conf_file).with(
        owner: dd_user,
        group: dd_group,
        mode: '0644',
      )}
      it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

      context 'with default parameters' do
        it { should contain_file(conf_file).with_content(%r{kong_status_url: http://localhost:8001/status/}) }
      end

      context 'with params set' do
        let(:params) {{
          instances: [
            {
              'status_url' => 'http://foo.bar:8080/status/',
              'tags' => ['baz']
            }
          ]
        }}

        it { should contain_file(conf_file).with_content(%r{tags:\n.*- baz}) }
        it { should contain_file(conf_file).with_content(%r{kong_status_url: http://foo.bar:8080/status/}) }
      end
    end
  end
end
