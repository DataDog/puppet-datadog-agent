require 'spec_helper'

describe 'datadog_agent::integrations::apache' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/apache.yaml'
                  else
                    "#{CONF_DIR}/apache.d/conf.yaml"
                  end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('datadog_agent') }
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
        it { is_expected.to contain_file(conf_file).with_content(%r{apache_status_url: http://localhost/server-status\?auto}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{tags:}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{apache_user:}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{apache_password:}) }
      end

      context 'with parameters set' do
        let(:params) do
          {
            url: 'http://foobar',
            username: 'userfoo',
            password: 'passfoo',
            tags: ['foo', 'bar', 'baz'],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{apache_status_url: http://foobar}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{apache_user: userfoo}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{apache_password: passfoo}) }
      end

      context 'with tags parameter single value' do
        let(:params) do
          {
            tags: 'foo',
          }
        end

        it { is_expected.not_to compile }

        skip 'this is currently unimplemented behavior' do
          it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+- foo\s*?[^-]}m) }
        end
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
