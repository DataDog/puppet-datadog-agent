require 'spec_helper'

describe 'datadog_agent::integrations::kubernetes' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/kubernetes.yaml'
                  else
                    "#{CONF_DIR}/kubernetes.d/conf.yaml"
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
        it { is_expected.to contain_file(conf_file).with_content(%r{api_server_url: Enter_Your_API_url}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{apiserver_client_crt: /path/to/crt}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{apiserver_client_key: /path/to/key}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{kubelet_client_crt: /path/to/crt}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{kubelet_client_key: /path/to/key}) }
      end

      context 'with parameters set' do
        let(:params) do
          {
            api_server_url: 'unix://foo/bar/baz.sock',
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{api_server_url: unix://foo/bar/baz.sock}) }
      end

      context 'with tags parameter array' do
        let(:params) do
          {
            tags: ['foo', 'bar', 'baz'],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+- foo\s+- bar\s+- baz\s*?[^-]}m) }
      end

      context 'with tags parameter empty values' do
        context 'mixed in with other tags' do
          let(:params) do
            {
              tags: ['foo', '', 'baz'],
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+- foo\s+- baz\s*?[^-]}m) }
        end

        context 'single element array of an empty string' do
          let(:params) do
            {
              tags: [''],
            }
          end

          skip('undefined behavior')
        end

        context 'single value empty string' do
          let(:params) do
            {
              tags: '',
            }
          end

          skip('doubly undefined behavior')
        end
      end
    end
  end
end
