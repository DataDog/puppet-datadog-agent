require 'spec_helper'

describe 'datadog_agent::integrations::docker_daemon' do

  if RSpec::Support::OS.windows?
    # Check not supported on Windows
    return
  end

  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/docker.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/docker.d/conf.yaml" }
      end

      it { should compile.with_all_deps }
      it { should contain_file(conf_file).with(
        owner: DD_USER,
        group: DD_GROUP,
        mode: PERMISSIONS_FILE,
      )}
      it { should contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with default parameters' do
        it { should contain_file(conf_file).with_content(%r{url: unix://var/run/docker.sock}) }
      end

      context 'with parameters set' do
        let(:params) {{
          url: 'unix://foo/bar/baz.sock',
        }}
        it { should contain_file(conf_file).with_content(%r{url: unix://foo/bar/baz.sock}) }
      end

      context 'with tags parameter array' do
        let(:params) {{
          tags: %w{ foo bar baz },
        }}
        it { should contain_file(conf_file).with_content(%r{tags: \["foo", "bar", "baz"\]}) }
      end

      context 'with tags parameter with an empty tag' do
      end

      context 'with tags parameter empty values' do
        context 'mixed in with other tags' do
          let(:params) {{
            tags: [ 'foo', '', 'baz' ]
          }}

          it { should contain_file(conf_file).with_content(%r{tags: \["foo", "baz"\]}) }
        end

        context 'single element array of an empty string' do
          let(:params) {{
            tags: [''],
          }}

          it { should contain_file(conf_file).with_content(%r{tags: \[\]}) }
        end

        context 'single value empty string' do
          let(:params) {{
            tags: '',
          }}

          it { should contain_file(conf_file).with_content(%r{tags: \[\]}) }
        end
      end
    end
  end
end
