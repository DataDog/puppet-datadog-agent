require 'spec_helper'

describe 'datadog_agent::integrations::postfix' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/postfix.yaml'
                  else
                    "#{CONF_DIR}/postfix.d/conf.yaml"
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
        it { is_expected.to contain_file(conf_file).with_content(%r{  - directory: /var/spool/postfix}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{    queues:}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      - active}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      - deferred}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      - incoming}) }
      end

      context 'with parameters set' do
        let(:params) do
          {
            directory: '/var/spool/foobaz',
            queues:    ['foobar'],
            tags:      ['tag1:value1'],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{  - directory: /var/spool/foobaz}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{    queues:}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      - foobar}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{    tags:}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{      - tag1:value1}) }
      end

      context 'with multiple instances set' do
        let(:params) do
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

            ],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{instances:}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{  - directory: /var/spool/postfix-2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{    queues:\n      - active}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{    tags:\n      - tag2:value2}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{  - directory: /var/spool/postfix-3}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{    queues:\n      - incoming}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{    tags:\n      - tag3:value3}) }
      end
    end
  end
end
