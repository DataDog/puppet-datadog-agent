require 'spec_helper'

describe 'datadog_agent::integrations::twemproxy' do
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
      let(:conf_file) { "#{conf_dir}/twemproxy.yaml" }

      it { should compile.with_all_deps }
      it { should contain_file(conf_file).with(
        owner: dd_user,
        group: dd_group,
        mode: '0600',
      )}
      it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

      context 'with default parameters' do
        it { should contain_file(conf_file).with_content(%r{host: localhost}) }
        it { should contain_file(conf_file).with_content(%r{port: 22222}) }
      end

      context 'with parameters set' do
        let(:params) {{
          instances: [
            {
              'host' => 'twemproxy1',
              'port' => '1234',
            },
            {
              'host' => 'twemproxy2',
              'port' => '4567',
            }
          ]
        }}
        it { should contain_file(conf_file).with_content(%r{host: twemproxy1}) }
        it { should contain_file(conf_file).with_content(%r{port: 1234}) }
        it { should contain_file(conf_file).with_content(%r{host: twemproxy2}) }
        it { should contain_file(conf_file).with_content(%r{port: 4567}) }
      end
    end
  end
end
