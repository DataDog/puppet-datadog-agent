require 'spec_helper'

describe 'datadog_agent::integrations::directory' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/directory.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/directory.d/conf.yaml" }
      end

      context 'with default parameters' do
        it { should_not compile }
      end

      context 'with directory parameter set' do
        let(:params) {{
          directory: '/var/log/datadog',
        }}
        
        it { should compile.with_all_deps }
        it { should contain_file(conf_file).with(
          owner: DD_USER,
          group: DD_GROUP,
          mode: PERMISSIONS_PROTECTED_FILE,
        )}

        it { should contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
        it { should contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }


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
