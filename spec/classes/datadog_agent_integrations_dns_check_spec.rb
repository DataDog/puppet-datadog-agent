require 'spec_helper'

describe 'datadog_agent::integrations::dns_check' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/dns_check.yaml'
                  else
                    "#{CONF_DIR}/dns_check.d/conf.yaml"
                  end

      it { is_expected.to compile.with_all_deps }
      it {
        is_expected.to contain_file(conf_file).with(
          owner: DD_USER,
          group: DD_GROUP,
          mode: PERMISSIONS_PROTECTED_FILE,
        )
      }
      it { is_expected.to contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { is_expected.to contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with default parameters' do
        it { is_expected.to contain_file(conf_file).with_content(%r{hostname: google.com}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{nameserver: 8.8.8.8}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{timeout: 5}) }
      end

      context 'with parameters set' do
        let(:params) do
          {
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
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{hostname: example.com}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{nameserver: 1.2.3.4}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{timeout: 5}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{hostname: localdomain.com}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{nameserver: 4.3.2.1}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{timeout: 3}) }
      end
    end
  end
end
