require 'spec_helper'

describe "datadog_agent::install_integration" do

  describe "installing an integration" do
    let(:pre_condition) { "class {'::datadog_agent': }" }
    let (:title) { "test" }
    let (:params) {{
      :integration_name => "datadog-mongo",
      :version => "1.9.0",
    }}

    it { should compile }

    it { is_expected.to contain_exec("install datadog-mongo==1.9.0").with_command("/opt/datadog-agent/bin/agent/agent integration install datadog-mongo==1.9.0") }

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

    it { is_expected.to contain_exec("remove datadog-mongo==1.9.0").with_command("/opt/datadog-agent/bin/agent/agent integration remove datadog-mongo==1.9.0") }

  end
end
