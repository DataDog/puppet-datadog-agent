require 'spec_helper'

describe "datadog_agent::install_integration" do
  context 'all supported operating systems' do
    ALL_OS.each do |operatingsystem|
      let(:facts) do {
          operatingsystem: operatingsystem,
          osfamily: getosfamily(operatingsystem),
          operatingsystemrelease: getosrelease(operatingsystem),
        }
      end

      if WINDOWS_OS.include?(operatingsystem)
        let (:agent_binary) { 'C:/Program Files/Datadog/Datadog Agent/embedded/agent.exe' }
      else
        let (:agent_binary) { '/opt/datadog-agent/bin/agent/agent' }
      end

      describe "installing an integration" do
        let(:pre_condition) { "class {'::datadog_agent': }" }
        let (:title) { "test" }
        let (:params) {{
          :integration_name => "datadog-mongo",
          :version => "1.9.0",
        }}

        it { should compile }

        it { is_expected.to contain_exec("install datadog-mongo==1.9.0").with_command("#{agent_binary} integration install datadog-mongo==1.9.0") }

      end

      describe "removing an integration" do
        let(:pre_condition) { "class {'::datadog_agent': }" }
        let (:title) { "test" }
        let (:params) {{
          :integration_name => "datadog-mongo",
          :version => "1.9.0",
          :ensure => "absent",
        }}

        it { should compile }

        it { is_expected.to contain_exec("remove datadog-mongo==1.9.0").with_command("#{agent_binary} integration remove datadog-mongo==1.9.0") }

      end
    end
  end
end
