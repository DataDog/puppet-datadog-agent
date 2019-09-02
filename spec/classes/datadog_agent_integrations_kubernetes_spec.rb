require 'spec_helper'

describe 'datadog_agent::integrations::kubernetes' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/kubernetes.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/kubernetes.d/conf.yaml" }
      end

      it { should compile.with_all_deps }
      it { should contain_file(conf_file).with(
        owner: DD_USER,
        group: DD_GROUP,
        mode: '0664',
      )}
      it { should contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with default parameters' do
        it { should contain_file(conf_file).with_content(%r{api_server_url: Enter_Your_API_url}) }
        it { should contain_file(conf_file).with_content(%r{apiserver_client_crt: /path/to/crt}) }
        it { should contain_file(conf_file).with_content(%r{apiserver_client_key: /path/to/key}) }
        it { should contain_file(conf_file).with_content(%r{kubelet_client_crt: /path/to/crt}) }
        it { should contain_file(conf_file).with_content(%r{kubelet_client_key: /path/to/key}) }
      end

      context 'with parameters set' do
        let(:params) {{
          api_server_url: 'unix://foo/bar/baz.sock',
        }}
        it { should contain_file(conf_file).with_content(%r{api_server_url: unix://foo/bar/baz.sock}) }
      end

      context 'with tags parameter array' do
        let(:params) {{
          tags: %w{ foo bar baz },
        }}
        it { should contain_file(conf_file).with_content(/tags:\s+- foo\s+- bar\s+- baz\s*?[^-]/m) }
      end

      context 'with tags parameter with an empty tag' do
      end

      context 'with tags parameter empty values' do
        context 'mixed in with other tags' do
          let(:params) {{
            tags: [ 'foo', '', 'baz' ]
          }}

          it { should contain_file(conf_file).with_content(/tags:\s+- foo\s+- baz\s*?[^-]/m) }
        end

        context 'single element array of an empty string' do
          let(:params) {{
            tags: [''],
          }}

          skip("undefined behavior")
        end

        context 'single value empty string' do
          let(:params) {{
            tags: '',
          }}

          skip("doubly undefined behavior")
        end
      end
    end
  end
end
