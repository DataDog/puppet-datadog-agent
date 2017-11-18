require 'spec_helper'

describe 'datadog_agent::integrations::ssh' do
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
      let(:conf_file) { "#{conf_dir}/ssh.yaml" }

      context 'with default parameters' do
        it { should compile }
      end

      context 'with parameters set' do
        let(:params) {{
          host: 'localhost',
          port:  222,
          username: 'foo',
          password: 'bar',
          sftp_check: false,
        }}
        it { should contain_file(conf_file).with_content(/host: localhost/) }
        it { should contain_file(conf_file).with_content(/port: 222/) }
        it { should contain_file(conf_file).with_content(/username: foo/) }
        it { should contain_file(conf_file).with_content(/password: bar/) }
        it { should contain_file(conf_file).without_content(/private_key_file:/) }
      end
    end
  end
end
