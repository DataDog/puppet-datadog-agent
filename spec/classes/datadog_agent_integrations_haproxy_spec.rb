require 'spec_helper'

describe 'datadog_agent::integrations::haproxy' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }
      let(:facts) do
        {
          networking: { 'ip' => '1.2.3.4' },
        }
      end

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/haproxy.yaml'
                  else
                    "#{CONF_DIR}/haproxy.d/conf.yaml"
                  end

      it { is_expected.to compile.with_all_deps }
      it {
        is_expected.to contain_file(conf_file).with(
          owner: DD_USER,
          group: DD_GROUP,
          mode: PERMISSIONS_FILE,
        )
      }
      it { is_expected.to contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { is_expected.to contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with default parameters' do
        it { is_expected.to contain_file(conf_file).with_content(%r{url: http://1.2.3.4:8080}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{username: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{password: }) }
      end

      context 'with url set' do
        let(:params) do
          {
            url: 'http://foo.bar:8421',
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{url: http://foo.bar:8421}) }
      end

      context 'with creds set correctly' do
        let(:params) do
          {
            creds: {
              'username' => 'foo',
              'password' => 'bar',
            },
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{username: foo}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{password: bar}) }
      end

      context 'with creds set incorrectly' do
        let(:params) do
          {
            'invalid' => 'is this real life',
          }
        end

        skip 'functionality not yet implemented' do
          it { is_expected.to contain_file(conf_file).without_content(%r{invalid: is this real life}) }
        end
      end

      context 'with options set' do
        let(:params) do
          {
            options: {
              'optionk' => 'optionv',
            },
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{optionk: optionv}) }
      end

      context 'with instances set' do
        let(:params) do
          {
            instances: [
              {
                'url'     => 'http://foo.bar:8421',
                'creds'   => {
                  'username' => 'foo',
                  'password' => 'bar',
                },
                'options' => {
                  'optionk1' => 'optionv1',
                },
              },
              {
                'url'     => 'http://shoe.baz:1248',
                'creds'   => {
                  'username' => 'shoe',
                  'password' => 'baz',
                },
                'options' => {
                  'optionk2' => 'optionv2',
                },
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{url: http://foo.bar:8421}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{username: foo}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{password: bar}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{optionk1: optionv1}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{url: http://shoe.baz:1248}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{username: shoe}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{password: baz}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{optionk2: optionv2}) }
      end
    end
  end
end
