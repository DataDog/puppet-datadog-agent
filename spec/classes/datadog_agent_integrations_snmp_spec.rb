require 'spec_helper'

describe 'datadog_agent::integrations::snmp' do
  context 'supported agents - v5 and v6' do
    agents = { '5' => true, '6' => false }
    agents.each do |_, is_agent5|
      if is_agent5
        let(:conf_dir) { '/etc/dd-agent/conf.d' }
      else
        let(:conf_dir) { '/etc/datadog-agent/conf.d' }
      end
      let(:dd_user) { 'dd-agent' }
      let(:dd_group) { 'root' }
      let(:dd_package) { 'datadog-agent' }
      let(:dd_service) { 'datadog-agent' }
      if is_agent5
        let(:conf_file) { "#{conf_dir}/snmp.yaml" }
      else
        let(:conf_file) { "#{conf_dir}/snmp.d/conf.yaml" }
      end

      it { should compile.with_all_deps }
      it {should contain_file(conf_file).with(
        owner: dd_user,
        group: dd_group,
        mode: '0600',
      )}
      it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

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
