require 'spec_helper'

describe 'datadog_agent::integrations::nginx' do
  context 'supported agents - v5 and v6' do
    agents = { '5' => false, '6' => true }
    agents.each do |_, enabled|
      let(:pre_condition) { "class {'::datadog_agent': agent6_enable => #{enabled}}" }
      let(:facts) {{
        operatingsystem: 'Ubuntu',
      }}
      if !enabled
        let(:conf_dir) { '/etc/dd-agent/conf.d' }
      else
        let(:conf_dir) { '/etc/datadog-agent/conf.d' }
      end
      let(:dd_user) { 'dd-agent' }
      let(:dd_group) { 'root' }
      let(:dd_package) { 'datadog-agent' }
      let(:dd_service) { 'datadog-agent' }
      let(:conf_file) { "#{conf_dir}/nginx.yaml" }

      it { should compile.with_all_deps }
      it { should contain_file(conf_file).with(
        owner: dd_user,
        group: dd_group,
        mode: '0600',
      )}
      it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

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
          ]
        }}

        it { should contain_file(conf_file).with_content(%r{nginx_status_url:.*http://foo.bar:1941/check}m) }
        it { should contain_file(conf_file).with_content(%r{tags:.*foo.*bar.*baz}m) }
      end
    end
  end
end
