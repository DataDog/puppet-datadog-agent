require 'spec_helper'

describe 'datadog_agent::integrations::mongo' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/mongo.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/mongo.d/conf.yaml" }
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
        it { should contain_file(conf_file).with_content(%r{- server: mongodb://localhost:27017}) }
        it { should contain_file(conf_file).without_content(%r{tags:}) }
      end

      context 'with one mongo' do
        let(:params) {{
          servers: [
            {
              'host' => '127.0.0.1',
              'port' => '12345',
              'tags' => %w{ foo bar baz },
            }
          ]
        }}

        it { should contain_file(conf_file).with_content(%r{server: mongodb://127.0.0.1:12345/\s+tags:\s+- foo\s+- bar\s+- baz}) }
      end

      context 'with multiple mongos' do
        let(:params) {{
          servers: [
            {
              'host' => '127.0.0.1',
              'port' => '34567',
              'tags' => %w{foo bar},
            },
            {
              'host' => '127.0.0.2',
              'port' => '45678',
              'tags' => %w{baz bat},
            }
          ]
        }}
        it { should contain_file(conf_file).with_content(%r{server: mongodb://127.0.0.1:34567/\s+tags:\s+- foo\s+- bar}) }
        it { should contain_file(conf_file).with_content(%r{server: mongodb://127.0.0.2:45678/\s+tags:\s+- baz\s+- bat}) }
        it { should contain_file(conf_file).with_content(%r{server:.*127.0.0.1.*server:.*127.0.0.2}m) }
      end

      context 'with custom collections one mongos' do
        let(:params) {{
          servers: [
            {
              'host' => '127.0.0.1',
              'port' => '12345',
              'tags' => %w{ foo bar baz },
              'collections' => %w{ collection_1 collection_2 },
            },
            {
              'host' => '127.0.0.2',
              'port' => '45678',
              'tags' => %w{baz bat},
              'collections' => %w{ collection_1 collection_2 },
            }
          ]
        }}

        it { should contain_file(conf_file).with_content(%r{server: mongodb://127.0.0.1:12345/\s+tags:\s+- foo\s+- bar\s+- baz\s+collections:\s+- collection_1\s+- collection_2}) }
        it { should contain_file(conf_file).with_content(%r{server: mongodb://127.0.0.2:45678/\s+tags:\s+- baz\s+- bat\s+collections:\s+- collection_1\s+- collection_2}) }

      end

      context 'with custom collections multiple mongo' do
        let(:params) {{
          servers: [
            {
              'host' => '127.0.0.1',
              'port' => '12345',
              'tags' => %w{ foo bar baz },
              'collections' => %w{ collection_1 collection_2 },
            }
          ]
        }}

        it { should contain_file(conf_file).with_content(%r{server: mongodb://127.0.0.1:12345/\s+tags:\s+- foo\s+- bar\s+- baz\s+collections:\s+- collection_1\s+- collection_2}) }
      end

      context 'with additional metrics' do
        let(:params) {{
          servers: [
            {
              'host' => '127.0.0.1',
              'port' => '12345',
              'tags' => %w{ foo bar baz },
              'additional_metrics' => %w{ top },
            }
          ]
        }}

        it { should contain_file(conf_file).with_content(%r{server: mongodb://127.0.0.1:12345/\s+tags:\s+- foo\s+- bar\s+- baz\s+additional_metrics:\s+- top}) }
      end

      context 'without tags' do
        let(:params) {{
          servers: [
            {
              'host' => '127.0.0.1',
              'port' => '12345',
            }
          ]
        }}

      end

      context 'weird tags' do
        let(:params) {{
          servers: [
            {
              'host' => '127.0.0.1',
              'port' => '56789',
              'tags' => 'word'
            }
          ]
        }}
        it { should_not compile }
      end
    end
  end
end
