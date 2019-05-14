require 'spec_helper'

describe 'datadog_agent::integrations::kafka' do
  context 'supported agents - v5 and v6' do
    agents = { '5' => true, '6' => false }
    agents.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      let(:facts) {{
        operatingsystem: 'Ubuntu',
      }}
      if is_agent5
        let(:conf_dir) { '/etc/dd-agent/conf.d' }
      else
        let(:conf_dir) { '/etc/datadog-agent/conf.d' }
      end

      let(:dd_user) { 'dd-agent' }
      let(:dd_group) { 'root' }
      let(:dd_package) { 'datadog-agent' }
      let(:dd_service) { 'datadog-agent' }
      if is_agent5
        let(:conf_file) { "#{conf_dir}/kafka.yaml" }
      else
        let(:conf_file) { "#{conf_dir}/kafka.d/conf.yaml" }
      end

      it { should compile.with_all_deps }
      it { should contain_file(conf_file).with(
        owner: dd_user,
        group: dd_group,
        mode: '0600',
      )}
      it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
      it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

      context 'with default parameters' do
        it { should contain_file(conf_file).with_content(%r{- host: localhost\s+port: 9999}) }
        it { should contain_file(conf_file).without_content(%r{user:}) }
      end

      context 'with one kafka broker' do
        let(:params) {{
          instances: [
            {
              'host' => 'localhost',
              'port' => '9997',
              'tags' => %w{ kafka:broker tag1:value1 },
            }
          ]
        }}

        it { should contain_file(conf_file).with_content(%r{host: localhost\s+port: 9997\s+tags:\s+- kafka:broker\s+- tag1:value1}) }
      end

      context 'with two kafka brokers' do
        let(:params) {{
          instances: [
            {
              'host' => 'localhost',
              'port' => '9997',
              'tags' => %w{ kafka:broker tag1:value1 },
            },
            {
              'host' => 'remotehost',
              'port' => '9998',
              'tags' => %w{ kafka:remote tag2:value2 },
            }
          ]
        }}

        it { should contain_file(conf_file).with_content(%r{host: localhost\s+port: 9997\s+tags:\s+- kafka:broker\s+- tag1:value1}) }
        it { should contain_file(conf_file).with_content(%r{host: remotehost\s+port: 9998\s+tags:\s+- kafka:remote\s+- tag2:value2}) }

      end

      context 'one kafka broker all options' do
        let(:params) {{
          instances: [
            {
              'host' => 'localhost',
              'port' => '9997',
              'tags' => %w{ kafka:broker tag1:value1 },
              'username' => 'username',
              'password' => 'password',
              'process_name_regex' => 'regex',
              'tools_jar_path' => 'tools.jar',
              'name' => 'kafka_instance',
              'java_bin_path' => '/path/to/java',
              'trust_store_path' => '/path/to/trustStore.jks',
              'trust_store_password' => 'password'
            }
          ]
        }}

        it { should contain_file(conf_file).with_content(%r{host: localhost\s+port: 9997\s+tags:\s+- kafka:broker\s+- tag1:value1\s+user: username\s+password: password\s+process_name_regex: regex\s+tools_jar_path: tools.jar\s+name: kafka_instance\s+java_bin_path: /path/to/java\s+trust_store_path: /path/to/trustStore.jks\s+trust_store_password: password}) }
      end
    end
  end
end
