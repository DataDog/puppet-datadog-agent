require 'spec_helper'

describe 'datadog_agent::integrations::snmp' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/snmp.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/snmp.d/conf.yaml" }
      end

      it { should compile.with_all_deps }
      it {should contain_file(conf_file).with(
        owner: DD_USER,
        group: DD_GROUP,
        mode: PERMISSIONS_PROTECTED_FILE,
      )}
      it { should contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with default parameters' do
        it { should contain_file(conf_file).without_content(/ignore_nonincreasing_oid/) }
      end

      context 'with parameters set' do
        let(:params) {{
            ignore_nonincreasing_oid: true,
        }}
        it { should contain_file(conf_file).with_content(/ignore_nonincreasing_oid: true/) }
      end
    end
  end
end
