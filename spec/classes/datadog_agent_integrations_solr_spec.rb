require 'spec_helper'

describe 'datadog_agent::integrations::solr' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/solr.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/solr.d/conf.yaml" }
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
        it { should contain_file(conf_file).with_content(%r{host: localhost}) }
        it { should contain_file(conf_file).with_content(%r{port: 7199}) }
        it { should contain_file(conf_file).without_content(%r{user:}) }
        it { should contain_file(conf_file).without_content(%r{password:}) }
        it { should contain_file(conf_file).without_content(%r{java_bin_path:}) }
        it { should contain_file(conf_file).without_content(%r{trust_store_path:}) }
        it { should contain_file(conf_file).without_content(%r{trust_store_password:}) }
      end

      context 'with parameters set' do
        let(:params) {{
          hostname: 'solr1',
          port: 867,
          username: 'userfoo',
          password: 'passbar',
          java_bin_path: '/opt/java/bin',
          trust_store_path: '/var/lib/solr/trust_store',
          trust_store_password: 'hunter2',
          tags: {
            'foo' => 'bar',
            'baz' => 'bat',
          }
        }}
        it { should contain_file(conf_file).with_content(%r{host: solr1}) }
        it { should contain_file(conf_file).with_content(%r{port: 867}) }
        it { should contain_file(conf_file).with_content(%r{user: userfoo}) }
        it { should contain_file(conf_file).with_content(%r{password: passbar}) }
        it { should contain_file(conf_file).with_content(%r{java_bin_path: /opt/java/bin}) }
        it { should contain_file(conf_file).with_content(%r{trust_store_path: /var/lib/solr/trust_store}) }
        it { should contain_file(conf_file).with_content(%r{trust_store_password: hunter2}) }
        it { should contain_file(conf_file).with_content(%r{tags:\s+foo: bar\s+baz: bat}) }
      end
    end
  end
end
