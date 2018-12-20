require 'spec_helper'

describe 'datadog_agent::integrations::redis' do
  context 'supported agents - v5 and v6' do
    agents = { '5' => true, '6' => false }
    agents.each do |_, enabled|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{enabled}}" }
      let(:facts) {{
        operatingsystem: 'Ubuntu',
      }}
      if enabled
        let(:conf_dir) { '/etc/dd-agent/conf.d' }
      else
        let(:conf_dir) { '/etc/datadog-agent/conf.d' }
      end
      let(:dd_user) { 'dd-agent' }
      let(:dd_group) { 'root' }
      let(:dd_package) { 'datadog-agent' }
      let(:dd_service) { 'datadog-agent' }
      if enabled
        let(:conf_file) { "#{conf_dir}/redisdb.yaml" }
      else
        let(:conf_file) { "#{conf_dir}/redisdb.d/conf.yaml" }
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
        it { should contain_file(conf_file).with_content(%r{host: localhost}) }
        it { should contain_file(conf_file).without_content(%r{^[^#]*password: }) }
        it { should contain_file(conf_file).with_content(%r{port: 6379}) }
        it { should contain_file(conf_file).without_content(%r{^[^#]*slowlog-max-len: }) }
        it { should contain_file(conf_file).without_content(%r{tags:}) }
        it { should contain_file(conf_file).without_content(%r{\bkeys:}) }
        it { should contain_file(conf_file).with_content(%r{warn_on_missing_keys: true}) }
        it { should contain_file(conf_file).with_content(%r{command_stats: false}) }
      end

      context 'with parameters set' do
        let(:params) {{
          host: 'redis1',
          password: 'hunter2',
          port: 867,
          slowlog_max_len: '5309',
          tags: %w{foo bar},
          keys: %w{baz bat},
          warn_on_missing_keys: false,
          command_stats: true,
        }}
        it { should contain_file(conf_file).with_content(%r{host: redis1}) }
        it { should contain_file(conf_file).with_content(%r{^[^#]*password: hunter2}) }
        it { should contain_file(conf_file).with_content(%r{port: 867}) }
        it { should contain_file(conf_file).with_content(%r{^[^#]*slowlog-max-len: 5309}) }
        it { should contain_file(conf_file).with_content(%r{tags:.*\s+- foo\s+- bar}) }
        it { should contain_file(conf_file).with_content(%r{keys:.*\s+- baz\s+- bat}) }
        it { should contain_file(conf_file).with_content(%r{warn_on_missing_keys: false}) }
        it { should contain_file(conf_file).with_content(%r{command_stats: true}) }
      end
    end
  end
end
