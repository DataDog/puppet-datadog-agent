require 'spec_helper'

describe 'datadog_agent::integrations::kafka' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/kafka.yaml'
                  else
                    "#{CONF_DIR}/kafka.d/conf.yaml"
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
        it { is_expected.to contain_file(conf_file).with_content(%r{- host: localhost\s+port: 9999}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{user:}) }
      end

      context 'with one kafka broker' do
        let(:params) do
          {
            instances: [
              {
                'host' => 'localhost',
                'port' => '9997',
                'tags' => ['kafka:broker', 'tag1:value1'],
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{host: localhost\s+port: 9997\s+tags:\s+- kafka:broker\s+- tag1:value1}) }
      end

      context 'with two kafka brokers' do
        let(:params) do
          {
            instances: [
              {
                'host' => 'localhost',
                'port' => '9997',
                'tags' => ['kafka:broker', 'tag1:value1'],
              },
              {
                'host' => 'remotehost',
                'port' => '9998',
                'tags' => ['kafka:remote', 'tag2:value2'],
              },
            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{host: localhost\s+port: 9997\s+tags:\s+- kafka:broker\s+- tag1:value1}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{host: remotehost\s+port: 9998\s+tags:\s+- kafka:remote\s+- tag2:value2}) }
      end

      context 'one kafka broker all options' do
        let(:params) do
          {
            instances: [
              {
                'host' => 'localhost',
                'port' => '9997',
                'tags' => ['kafka:broker', 'tag1:value1'],
                'username' => 'username',
                'password' => 'password',
                'process_name_regex' => 'regex',
                'tools_jar_path' => 'tools.jar',
                'name' => 'kafka_instance',
                'java_bin_path' => '/path/to/java',
                'trust_store_path' => '/path/to/trustStore.jks',
                'trust_store_password' => 'password',
              },
            ],
          }
        end

        it {
          is_expected.to contain_file(conf_file).with_content(%r{host: localhost\s+port: 9997\s+tags:\s+- kafka:broker\s+- tag1:value1
\s+user: username\s+password: password\s+process_name_regex: regex\s+tools_jar_path: tools.jar\s+name: kafka_instance
\s+java_bin_path: /path/to/java\s+trust_store_path: /path/to/trustStore.jks\s+trust_store_password: password})
        }
      end
    end
  end
end
