require 'spec_helper'

describe 'datadog_agent::integrations::directory' do
  context 'supported agents - v5 and v6' do
    agents = { '5' => false, '6' => true }
    agents.each do |_, enabled|
      let(:pre_condition) { "class {'::datadog_agent': agent6_enable => #{enabled}}" }
      let(:facts) {{
        operatingsystem: 'Ubuntu',
      }}
      if !enabled
        let(:conf_dir) { '/etc/dd-agent/conf.d' }
      else
        let(:conf_dir) { '/etc/datadog-agent/conf.d' }
      end
      let(:dd_user) { 'dd-agent' }
      let(:dd_group) { 'root' }
      let(:dd_package) { 'datadog-agent' }
      let(:dd_service) { 'datadog-agent' }
      let(:conf_file) { "#{conf_dir}/directory.yaml" }

      context 'with default parameters' do
        it { should_not compile }
      end

      context 'with directory parameter set' do
        let(:params) {{
          directory: '/var/log/datadog',
        }}
        
        it { should compile.with_all_deps }
        it { should contain_file(conf_file).with(
          owner: dd_user,
          group: dd_group,
          mode: '0600',
        )}

        it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
        it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }


        context 'with default parameters' do
          it { should contain_file(conf_file).with_content(%r{directory: /var/log/datadog}) }
          it { should contain_file(conf_file).with_content(%r{filegauges: false}) }
          it { should contain_file(conf_file).with_content(%r{recursive: true}) }
          it { should contain_file(conf_file).with_content(%r{countonly: false}) }
          it { should contain_file(conf_file).without_content(/name:/) }
          it { should contain_file(conf_file).without_content(/dirtagname:/) }
          it { should contain_file(conf_file).without_content(/filetagname:/) }
          it { should contain_file(conf_file).without_content(/pattern:/) }
        end

        context 'with parameters set' do
          let(:params) {{
            directory: '/var/log/datadog',
            nametag: 'doggielogs',
            dirtagname: 'doggiedirtag',
            filetagname: 'doggiefiletag',
          }}
          it { should contain_file(conf_file).with_content(%r{directory: /var/log/datadog}) }
          it { should contain_file(conf_file).with_content(/name: doggielogs/) }
          it { should contain_file(conf_file).with_content(/dirtagname: doggiedirtag/) }
          it { should contain_file(conf_file).with_content(/filetagname: doggiefiletag/) }
        end
      end

      context 'with multiple instances set' do
        let(:params) {
          {
            instances: [
              {
                'directory'   => '/var/log/datadog',
              },
              {
                'directory'   => '/var/log/syslog',
              }
            ]
          }
        }
        it { should contain_file(conf_file).with_content(%r{instances:}) }
        it { should contain_file(conf_file).with_content(%r{  - directory: /var/log/datadog}) }
        it { should contain_file(conf_file).with_content(%r{  - directory: /var/log/syslog}) }
      end
    end
  end
end
