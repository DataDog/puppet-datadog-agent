require 'spec_helper'

describe 'datadog_agent::integration' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      if agent_major_version == 5
        conf_file = '/etc/dd-agent/conf.d/test.yaml'
      else
        conf_dir = "#{CONF_DIR}/test.d"
        conf_file = "#{conf_dir}/conf.yaml"
      end

      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      let(:title) { 'test' }

      if agent_major_version > 5
        it { is_expected.to contain_file(conf_dir.to_s).that_comes_before("File[#{conf_file}]") }
      end
      it { is_expected.to contain_file(conf_file.to_s).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with instances' do
        let(:params) do
          {
            instances: [
              {
                one: 'two',
              },
            ],
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_file(conf_file.to_s).with_content(%r{---\s?\n\s*init_config:\s?\n\s*instances:\s?\n\s*- one: two}) }
        it { is_expected.to contain_file(conf_file).with_ensure('file') }
      end

      context 'with logs' do
        let(:params) do
          {
            instances: [
              {
                one: 'two',
              },
            ],
            logs: ['one', 'two'],
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_file(conf_file).with_content(%r{logs:\n\s*- one\n\s*- two}) }
        it { is_expected.to contain_file(conf_file).with_ensure('file') }
      end

      context 'with ensure absent' do
        let(:params) do
          {
            ensure: 'absent',
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_file(conf_file).with_ensure('absent') }
      end
    end
  end
end
