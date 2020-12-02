require 'spec_helper'

describe 'datadog_agent::integration' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |agent_major_version|
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }
      if agent_major_version == 5
        let(:conf_file) { '/etc/dd-agent/conf.d/test.yaml' }

      else
        let(:conf_dir) { "#{CONF_DIR}/test.d" }
        let(:conf_file) { "#{conf_dir}/conf.yaml" }
      end

      let(:title) { 'test' }

      gem_spec = Gem.loaded_specs['puppet']

      if agent_major_version == 5
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
        if gem_spec.version >= Gem::Version.new('4.0.0')
          it { is_expected.to contain_file(conf_file.to_s).with_content(%r{---\ninit_config: \ninstances:\n- one: two\n}) }
        else
          it { is_expected.to contain_file(conf_file.to_s).with_content(%r{--- \n  init_config: \n  instances: \n    - one: two}) }
        end
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
        if gem_spec.version >= Gem::Version.new('4.0.0')
          it { is_expected.to contain_file(conf_file).with_content(%r{logs:\n- one\n- two}) }
        else
          it { is_expected.to contain_file(conf_file).with_content(%r{logs:\n  - one\n  - two}) }
        end
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
