require 'spec_helper'

describe 'datadog_agent::integrations::varnish' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/varnish.yaml'
                  else
                    "#{CONF_DIR}/varnish.d/conf.yaml"
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
        it { is_expected.to contain_file(conf_file).with_content(%r{varnishstat: /usr/bin/varnishstat}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{tags: }) }
      end

      context 'with parameters set' do
        let(:params) do
          {
            varnishstat: '/opt/bin/varnishstat',
            tags: ['foo', 'bar', 'baz'],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{varnishstat: /opt/bin/varnishstat}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+- foo\s+- bar\s+- baz}) }
      end
    end
  end
end
