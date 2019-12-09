require 'spec_helper'

describe 'datadog_agent::integrations::ssh' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |agent_major_version|
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }
      if agent_major_version == 5
        let(:conf_file) { "/etc/dd-agent/conf.d/ssh.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR}/ssh_check.d/conf.yaml" }
      end

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
