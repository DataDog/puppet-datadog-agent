require 'spec_helper'

describe 'datadog_agent::integrations::supervisord' do
  context 'supported agents' do
    ALL_SUPPORTED_AGENTS.each do |_, is_agent5|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{is_agent5}}" }
      if is_agent5
        let(:conf_file) { "/etc/dd-agent/conf.d/supervisord.yaml" }
      else
        let(:conf_file) { "#{CONF_DIR6}/supervisord.d/conf.yaml" }
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
        it { should contain_file(conf_file).with_content(%r{name: server0\s+host: localhost\s+port: 9001}) }
      end

      context 'with one supervisord' do
        context 'without processes' do
          let(:params) {{
            instances: [
              {
                'servername' => 'server0',
                'socket'     => 'unix://var/run/supervisor.sock',
              },
            ]
          }}
          it { should contain_file(conf_file).with_content(%r{name: server0\s+socket: unix://var/run/supervisor.sock}) }
        end
        context 'with processes' do
          let(:params) {{
            instances: [
              {
                'servername' => 'server0',
                'socket'     => 'unix://var/run/supervisor.sock',
                'proc_names' => %w{ java apache2 },
              },
            ]
          }}
          it { should contain_file(conf_file).with_content(%r{name: server0\s+socket: unix://var/run/supervisor.sock\s+proc_names:\s+- java\s+- apache2}) }
        end
      end

      context 'with multiple supervisord' do
        context 'without processes parameter array' do
          let(:params) {{
            instances: [
              {
                'servername' => 'server0',
                'socket'   => 'unix://var/run/supervisor.sock',
              },
              {
                'servername' => 'server1',
                'hostname'   => 'localhost',
                'port'       => '9001',
              },
            ]
          }}
          it { should contain_file(conf_file).with_content(%r{name: server0\s+socket: unix://var/run/supervisor.sock}) }
          it { should contain_file(conf_file).with_content(%r{name: server1\s+host: localhost\s+port: 9001}) }
        end
        context 'with processes parameter array' do
          let(:params) {{
            instances: [
              {
                'servername' => 'server0',
                'socket'     => 'unix://var/run/supervisor.sock',
                'proc_names' => %w{ webapp nginx },
              },
              {
                'servername' => 'server1',
                'hostname'   => 'localhost',
                'port'       => '9001',
                'proc_names' => %w{ java apache2 },
              },
            ]
          }}
          it { should contain_file(conf_file).with_content(%r{name: server0\s+socket: unix://var/run/supervisor.sock\s+proc_names:\s+- webapp\s+- nginx}) }
          it { should contain_file(conf_file).with_content(%r{name: server1\s+host: localhost\s+port: 9001\s+proc_names:\s+- java\s+- apache2}) }
        end
      end
    end
  end
end
