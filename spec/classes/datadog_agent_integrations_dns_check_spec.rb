require 'spec_helper'

describe 'datadog_agent::integrations::dns_check' do
  context 'supported agents - v5 and v6' do
    agents = { '5' => true, '6' => false }
    agents.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      let(:facts) {{
        operatingsystem: 'Ubuntu',
      }}
      if is_agent5
        let(:conf_dir) { '/etc/dd-agent/conf.d' }
      else
        let(:conf_dir) { '/etc/datadog-agent/conf.d' }
      end
      let(:dd_user)    { 'dd-agent' }
      let(:dd_group)   { 'root' }
      let(:dd_package) { 'datadog-agent' }
      let(:dd_service) { 'datadog-agent' }
      if is_agent5
        let(:conf_file) { "#{conf_dir}/dns_check.yaml" }
      else
        let(:conf_file) { "#{conf_dir}/dns_check.d/conf.yaml" }
      end

      it { should compile.with_all_deps }
      it { should contain_file(conf_file).with(
        owner: dd_user,
        group: dd_group,
        mode: '0600',
      )}
      it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

      context 'with default parameters' do
        it { should contain_file(conf_file).with_content(%r{hostname: google.com}) }
        it { should contain_file(conf_file).with_content(%r{nameserver: 8.8.8.8}) }
        it { should contain_file(conf_file).with_content(%r{timeout: 5}) }
      end

      context 'with parameters set' do
        let(:params) {{
          checks: [
            {
              'hostname'   => 'example.com',
              'nameserver' => '1.2.3.4',
              'timeout'    => 5,
            },
            {
              'hostname'   => 'localdomain.com',
              'nameserver' => '4.3.2.1',
              'timeout'    => 3,
            }
          ]
        }}

        it { should contain_file(conf_file).with_content(%r{hostname: example.com}) }
        it { should contain_file(conf_file).with_content(%r{nameserver: 1.2.3.4}) }
        it { should contain_file(conf_file).with_content(%r{timeout: 5}) }
        it { should contain_file(conf_file).with_content(%r{hostname: localdomain.com}) }
        it { should contain_file(conf_file).with_content(%r{nameserver: 4.3.2.1}) }
        it { should contain_file(conf_file).with_content(%r{timeout: 3}) }
      end
    end
  end
end
