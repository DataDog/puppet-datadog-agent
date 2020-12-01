require 'spec_helper'

describe 'datadog_agent::integrations::rabbitmq' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/rabbitmq.yaml'
                  else
                    "#{CONF_DIR}/rabbitmq.d/conf.yaml"
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
        it { is_expected.to contain_file(conf_file).with_content(%r{rabbitmq_api_url:}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{rabbitmq_user: guest}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{rabbitmq_pass: guest}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{ssl_verify: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{tag_families: false}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{nodes:}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{nodes_regexes:}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{queues:}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{queues_regexes:}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{vhosts:}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{exchanges:}) }
        it { is_expected.to contain_file(conf_file).without_content(%r{exchanges_regexes:}) }
      end

      context 'with parameters set' do
        let(:params) do
          {
            url: 'http://rabbit1:15672/',
            username: 'foo',
            password: 'bar',
            ssl_verify: false,
            tag_families: true,
            nodes: ['node1', 'node2', 'node3'],
            nodes_regexes: ['^regex1', 'regex2$', 'regex3*'],
            queues: ['queue1', 'queue2', 'queue3'],
            queues_regexes: ['^regex4', 'regex5$', 'regex6*'],
            vhosts: ['vhost1', 'vhost2', 'vhost3'],
            exchanges: ['exchange1', 'exchange2', 'exchange3'],
            exchanges_regexes: ['^regex7', 'regex8$', 'regex9*'],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{rabbitmq_api_url: http://rabbit1:15672/}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{rabbitmq_user: foo}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{rabbitmq_pass: bar}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{ssl_verify: false}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{tag_families: true}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{nodes:\s+- node1\s+- node2\s+- node3}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{nodes_regexes:\s+- \^regex1\s+- regex2\$\s+- regex3\*}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{queues:\s+- queue1\s+- queue2\s+- queue3}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{queues_regexes:\s+- \^regex4\s+- regex5\$\s+- regex6\*}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{vhosts:\s+- vhost1\s+- vhost2\s+- vhost3}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{exchanges:\s+- exchange1\s+- exchange2\s+- exchange3}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{exchanges_regexes:\s+- \^regex7\s+- regex8\$\s+- regex9\*}) }
      end
    end
  end
end
