require 'spec_helper'

describe 'datadog_agent::integrations::dns_check' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/dns_check.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/dns_check.d/conf.yaml" }
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
