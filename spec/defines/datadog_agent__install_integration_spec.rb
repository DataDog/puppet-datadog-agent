require 'spec_helper'

describe 'datadog_agent::install_integration' do
  context 'all supported operating systems' do
    ALL_OS.each do |operatingsystem|
      let(:facts) do
        {
          operatingsystem: operatingsystem,
          osfamily: getosfamily(operatingsystem),
          operatingsystemrelease: getosrelease(operatingsystem),
        }
      end

      if WINDOWS_OS.include?(operatingsystem)
        let(:agent_binary) { 'C:/Program Files/Datadog/Datadog Agent/embedded/agent.exe' }
      else
        let(:agent_binary) { '/opt/datadog-agent/bin/agent/agent' }
      end

      describe 'installing a core integration' do
        let(:pre_condition) { "class {'::datadog_agent': }" }
        let(:title) { 'test' }
        let(:params) do
          {
            integration_name: 'datadog-mongo',
            version: '1.9.0',
          }
        end

        it { is_expected.to compile }

        it { is_expected.to contain_exec('install datadog-mongo==1.9.0').with_command("#{agent_binary} integration install datadog-mongo==1.9.0") }
      end

      describe 'installing a third-party integration' do
        let(:pre_condition) { "class {'::datadog_agent': }" }
        let(:title) { 'test' }
        let(:params) do
          {
            integration_name: 'datadog-aqua',
            version: '1.0.0',
            third_party: true,
          }
        end

        it { is_expected.to compile }

        it { is_expected.to contain_exec('install datadog-aqua==1.0.0').with_command("#{agent_binary} integration install --third-party datadog-aqua==1.0.0") }
      end

      describe 'removing an integration' do
        let(:pre_condition) { "class {'::datadog_agent': }" }
        let(:title) { 'test' }
        let(:params) do
          {
            integration_name: 'datadog-mongo',
            version: '1.9.0',
            ensure: 'absent',
          }
        end

        it { is_expected.to compile }

        it { is_expected.to contain_exec('remove datadog-mongo==1.9.0').with_command("#{agent_binary} integration remove datadog-mongo==1.9.0") }
      end
    end
  end
end
