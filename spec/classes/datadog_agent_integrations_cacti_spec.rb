require 'spec_helper'

describe 'datadog_agent::integrations::cacti' do
  context 'supported agents - v5 and v6' do
    agents = { '5' => true, '6' => false }
    agents.each do |agent, enabled|
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
      let(:agent5_enable) { enabled }
      let(:conf_file) { "#{conf_dir}/cacti.yaml" }

      context 'with default parameters' do
        it { should compile }
      end

      context 'with parameters set' do
        let(:params) {{
          mysql_host: 'localhost',
          mysql_user: 'foo',
          mysql_password: 'bar',
          rrd_path: 'path',
        }}
        it { should contain_file(conf_file).with_content(/mysql_host: localhost/) }
        it { should contain_file(conf_file).with_content(/mysql_user: foo/) }
        it { should contain_file(conf_file).with_content(/mysql_password: bar/) }
        it { should contain_file(conf_file).with_content(/rrd_path: path/) }
      end
    end
  end
end
