require 'spec_helper'

describe 'datadog_agent::integrations::postfix' do
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
        let(:conf_file) { "#{conf_dir}/postfix.yaml" }
      else
        let(:conf_file) { "#{conf_dir}/postfix.d/conf.yaml" }
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
