require 'spec_helper'

describe "datadog_agent::integration" do
    let (:title) { "test" }
    let(:facts) do
      {
        operatingsystem: 'CentOS',
        osfamily: 'redhat'
      }
    end
    let (:params) {{
        :instances => [
            { 'one' => "two" }
        ]
    }}
    it { should compile }
    it { should contain_file('/etc/dd-agent/conf.d/test.yaml').with_content(/init_config:/) }
    it { should contain_file('/etc/dd-agent/conf.d/test.yaml').with_content(/instances:/) }
    it { should contain_file('/etc/dd-agent/conf.d/test.yaml').with_content(/one: two/) }

    it { should contain_file('/etc/dd-agent/conf.d/test.yaml').that_notifies("Service[datadog-agent]") }
end
