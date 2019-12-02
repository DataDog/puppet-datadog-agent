require 'spec_helper'

describe 'datadog_agent::integrations::ntp' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |agent_major_version|
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }
      if agent_major_version == 5
        let(:conf_file) { "/etc/dd-agent/conf.d/ntp.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/ntp.d/conf.yaml" }
      end

      it { should compile.with_all_deps }
      it { should contain_file(conf_file).with(
        owner: DD_USER,
        group: DD_GROUP,
        mode: PERMISSIONS_PROTECTED_FILE,
      )}
      it { should contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with default parameters' do
        it { should contain_file(conf_file).with_content(/offset_threshold: 60/) }
      end

      context 'with parameters set' do
        let(:params) {{
          offset_threshold: 42,
        }}
        it { should contain_file(conf_file).with_content(/offset_threshold: 42/) }
      end
    end
  end
end
