require 'spec_helper'

describe 'datadog_agent::integrations::docker_daemon' do
  if RSpec::Support::OS.windows?
    # Check not supported on Windows
    return
  end

  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |agent_major_version|
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      if agent_major_version == 5
        let(:conf_file) { '/etc/dd-agent/conf.d/docker.yaml' }
      else
        let(:conf_file) { "#{CONF_DIR}/docker.d/conf.yaml" }
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
        it { is_expected.to contain_file(conf_file).with_content(%r{url: unix://var/run/docker.sock}) }
      end

      context 'with parameters set' do
        let(:params) do
          {
            url: 'unix://foo/bar/baz.sock',
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{url: unix://foo/bar/baz.sock}) }
      end

      context 'with tags parameter array' do
        let(:params) do
          {
            tags: ['foo', 'bar', 'baz'],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{tags: \["foo", "bar", "baz"\]}) }
      end

      context 'with tags parameter empty values' do
        context 'mixed in with other tags' do
          let(:params) do
            {
              tags: ['foo', '', 'baz'],
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{tags: \["foo", "baz"\]}) }
        end

        context 'single element array of an empty string' do
          let(:params) do
            {
              tags: [''],
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{tags: \[\]}) }
        end

        context 'single value empty string' do
          let(:params) do
            {
              tags: '',
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{tags: \[\]}) }
        end
      end
    end
  end
end
