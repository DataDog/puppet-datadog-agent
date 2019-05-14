require 'spec_helper'

describe 'datadog_agent::integrations::mesos_master' do
  context 'supported agents - v5 and v6' do
    agents = { '5' => true, '6' => false }
    agents.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      let(:facts) {{
        operatingsystem: 'Ubuntu',
      }}
      if is_agent5
        let(:conf_dir) { '/etc/dd-agent/conf.d' }
      else
        let(:conf_dir) { '/etc/datadog-agent/conf.d' }
      end
      let(:dd_user) { 'dd-agent' }
      let(:dd_group) { 'root' }
      let(:dd_package) { 'datadog-agent' }
      let(:dd_service) { 'datadog-agent' }
      if is_agent5
        let(:conf_file) { "#{conf_dir}/mesos_master.yaml" }
      else
        let(:conf_file) { "#{conf_dir}/mesos_master.d/conf.yaml" }
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
        it { should contain_file(conf_file).with_content(%r{default_timeout: 10}) }
        it { should contain_file(conf_file).with_content(%r{url: http://localhost:5050}) }
      end

      context 'with parameters set' do
        let(:params) {{
          mesos_timeout: 867,
          url: 'http://foo.bar.baz:5309',
        }}
        it { should contain_file(conf_file).with_content(%r{default_timeout: 867}) }
        it { should contain_file(conf_file).with_content(%r{url: http://foo.bar.baz:5309}) }
      end
    end
  end
end
