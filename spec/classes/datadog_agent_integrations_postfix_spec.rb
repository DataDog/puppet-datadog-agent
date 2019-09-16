require 'spec_helper'

describe 'datadog_agent::integrations::postfix' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/postfix.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/postfix.d/conf.yaml" }
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
        it { should contain_file(conf_file).with_content(%r{  - directory: /var/spool/postfix}) }
        it { should contain_file(conf_file).with_content(%r{    queues:}) }
        it { should contain_file(conf_file).with_content(%r{      - active}) }
        it { should contain_file(conf_file).with_content(%r{      - deferred}) }
        it { should contain_file(conf_file).with_content(%r{      - incoming}) }
      end

      context 'with parameters set' do
        let(:params) {{
          directory: '/var/spool/foobaz',
          queues:    ['foobar'],
          tags:      ['tag1:value1'],
        }}
        it { should contain_file(conf_file).with_content(%r{  - directory: /var/spool/foobaz}) }
        it { should contain_file(conf_file).with_content(%r{    queues:}) }
        it { should contain_file(conf_file).with_content(%r{      - foobar}) }
        it { should contain_file(conf_file).with_content(%r{    tags:}) }
        it { should contain_file(conf_file).with_content(%r{      - tag1:value1}) }
      end

      context 'with multiple instances set' do
        let(:params) {
          {
            instances: [
              {
                'directory' => '/var/spool/postfix-2',
                'queues'    => 'active',
                'tags'      => ['tag2:value2'],
              },
              {
                'directory' => '/var/spool/postfix-3',
                'queues'    => 'incoming',
                'tags'      => ['tag3:value3'],
              },
              
            ]
          }
        }
        it { should contain_file(conf_file).with_content(%r{instances:}) }
        it { should contain_file(conf_file).with_content(%r{  - directory: /var/spool/postfix-2}) }
        it { should contain_file(conf_file).with_content(%r{    queues:}) }
        it { should contain_file(conf_file).with_content(%r{      - active}) }
        it { should contain_file(conf_file).with_content(%r{    tags:}) }
        it { should contain_file(conf_file).with_content(%r{      - tag2:value2}) }
        it { should contain_file(conf_file).with_content(%r{  - directory: /var/spool/postfix-3}) }
        it { should contain_file(conf_file).with_content(%r{    queues:}) }
        it { should contain_file(conf_file).with_content(%r{      - incoming}) }
        it { should contain_file(conf_file).with_content(%r{    tags:}) }
        it { should contain_file(conf_file).with_content(%r{      - tag3:value3}) }
      end
    end
  end
end
