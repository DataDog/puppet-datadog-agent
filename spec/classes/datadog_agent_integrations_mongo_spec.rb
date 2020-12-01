require 'spec_helper'

describe 'datadog_agent::integrations::mongo' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/mongo.yaml'
                  else
                    "#{CONF_DIR}/mongo.d/conf.yaml"
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
        it { is_expected.to contain_file(conf_file).with_content(%r{- server: mongodb://localhost:27017}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{tags:}) }
      end

      context 'with one mongo' do
        let(:params) do
          {
            servers: [
              {
                'host' => '127.0.0.1',
                'port' => '12345',
                'tags' => ['foo', 'bar', 'baz'],
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{server: mongodb://127.0.0.1:12345/\s+tags:\s+- foo\s+- bar\s+- baz}) }
      end

      context 'with multiple mongos' do
        let(:params) do
          {
            servers: [
              {
                'host' => '127.0.0.1',
                'port' => '34567',
                'tags' => ['foo', 'bar'],
              },
              {
                'host' => '127.0.0.2',
                'port' => '45678',
                'tags' => ['baz', 'bat'],
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{server: mongodb://127.0.0.1:34567/\s+tags:\s+- foo\s+- bar}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{server: mongodb://127.0.0.2:45678/\s+tags:\s+- baz\s+- bat}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{server:.*127.0.0.1.*server:.*127.0.0.2}m) }
      end

      context 'with custom collections one mongos' do
        let(:params) do
          {
            servers: [
              {
                'host' => '127.0.0.1',
                'port' => '12345',
                'tags' => ['foo', 'bar', 'baz'],
                'collections' => ['collection_1', 'collection_2'],
              },
              {
                'host' => '127.0.0.2',
                'port' => '45678',
                'tags' => ['baz', 'bat'],
                'collections' => ['collection_1', 'collection_2'],
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{server: mongodb://127.0.0.1:12345/\s+tags:\s+- foo\s+- bar\s+- baz\s+collections:\s+- collection_1\s+- collection_2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{server: mongodb://127.0.0.2:45678/\s+tags:\s+- baz\s+- bat\s+collections:\s+- collection_1\s+- collection_2}) }
      end

      context 'with custom collections multiple mongo' do
        let(:params) do
          {
            servers: [
              {
                'host' => '127.0.0.1',
                'port' => '12345',
                'tags' => ['foo', 'bar', 'baz'],
                'collections' => ['collection_1', 'collection_2'],
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{server: mongodb://127.0.0.1:12345/\s+tags:\s+- foo\s+- bar\s+- baz\s+collections:\s+- collection_1\s+- collection_2}) }
      end

      context 'with additional metrics' do
        let(:params) do
          {
            servers: [
              {
                'host' => '127.0.0.1',
                'port' => '12345',
                'tags' => ['foo', 'bar', 'baz'],
                'additional_metrics' => ['top'],
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{server: mongodb://127.0.0.1:12345/\s+tags:\s+- foo\s+- bar\s+- baz\s+additional_metrics:\s+- top}) }
      end

      context 'without tags' do
        let(:params) do
          {
            servers: [
              {
                'host' => '127.0.0.1',
                'port' => '12345',
              },
            ],
          }
        end

        it { is_expected.to compile }
      end

      context 'weird tags' do
        let(:params) do
          {
            servers: [
              {
                'host' => '127.0.0.1',
                'port' => '56789',
                'tags' => 'word',
              },
            ],
          }
        end

        it { is_expected.not_to compile }
      end
    end
  end
end
