require 'spec_helper'

describe 'datadog_agent::integrations::ssh' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |agent_major_version|
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      if agent_major_version == 5
        let(:conf_file) { '/etc/dd-agent/conf.d/ssh.yaml' }
      else
        let(:conf_file) { "#{CONF_DIR}/ssh_check.d/conf.yaml" }
      end

      context 'with default parameters' do
        it { is_expected.to compile }
      end

      context 'with parameters set' do
        let(:params) do
          {
            host: 'localhost',
            port:  222,
            username: 'foo',
            password: 'bar',
            sftp_check: false,
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{host: localhost}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 222}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{username: foo}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{password: bar}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{private_key_file:}) }
      end
    end
  end
end
