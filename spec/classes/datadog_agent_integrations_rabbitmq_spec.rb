require 'spec_helper'

describe 'datadog_agent::integrations::rabbitmq' do
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
        let(:conf_file) { "#{conf_dir}/rabbitmq.yaml" }
      else
        let(:conf_file) { "#{conf_dir}/rabbitmq.d/conf.yaml" }
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
        it { should contain_file(conf_file).with_content(%r{rabbitmq_api_url:}) }
        it { should contain_file(conf_file).with_content(%r{rabbitmq_user: guest}) }
        it { should contain_file(conf_file).with_content(%r{rabbitmq_pass: guest}) }
        it { should contain_file(conf_file).with_content(%r{ssl_verify: true}) }
        it { should contain_file(conf_file).with_content(%r{tag_families: false}) }
        it { should contain_file(conf_file).without_content(%r{nodes:}) }
        it { should contain_file(conf_file).without_content(%r{nodes_regexes:}) }
        it { should contain_file(conf_file).without_content(%r{queues:}) }
        it { should contain_file(conf_file).without_content(%r{queues_regexes:}) }
        it { should contain_file(conf_file).without_content(%r{vhosts:}) }
        it { should contain_file(conf_file).without_content(%r{exchanges:}) }
        it { should contain_file(conf_file).without_content(%r{exchanges_regexes:}) }
      end

      context 'with parameters set' do
        let(:params) {{
          url: 'http://rabbit1:15672/',
          username: 'foo',
          password: 'bar',
          ssl_verify: false,
          tag_families: true,
          nodes: %w{ node1 node2 node3 },
          nodes_regexes: %w{ ^regex1 regex2$ regex3* },
          queues: %w{ queue1 queue2 queue3 },
          queues_regexes: %w{ ^regex4 regex5$ regex6* },
          vhosts: %w{ vhost1 vhost2 vhost3 },
          exchanges: %w{ exchange1 exchange2 exchange3 },
          exchanges_regexes: %w{ ^regex7 regex8$ regex9* },
        }}
        it { should contain_file(conf_file).with_content(%r{rabbitmq_api_url: http://rabbit1:15672/}) }
        it { should contain_file(conf_file).with_content(%r{rabbitmq_user: foo}) }
        it { should contain_file(conf_file).with_content(%r{rabbitmq_pass: bar}) }
        it { should contain_file(conf_file).with_content(%r{ssl_verify: false}) }
        it { should contain_file(conf_file).with_content(%r{tag_families: true}) }
        it { should contain_file(conf_file).with_content(%r{nodes:\s+- node1\s+- node2\s+- node3}) }
        it { should contain_file(conf_file).with_content(%r{nodes_regexes:\s+- \^regex1\s+- regex2\$\s+- regex3\*}) }
        it { should contain_file(conf_file).with_content(%r{queues:\s+- queue1\s+- queue2\s+- queue3}) }
        it { should contain_file(conf_file).with_content(%r{queues_regexes:\s+- \^regex4\s+- regex5\$\s+- regex6\*}) }
        it { should contain_file(conf_file).with_content(%r{vhosts:\s+- vhost1\s+- vhost2\s+- vhost3}) }
        it { should contain_file(conf_file).with_content(%r{exchanges:\s+- exchange1\s+- exchange2\s+- exchange3}) }
        it { should contain_file(conf_file).with_content(%r{exchanges_regexes:\s+- \^regex7\s+- regex8\$\s+- regex9\*}) }
      end
    end
  end
end
