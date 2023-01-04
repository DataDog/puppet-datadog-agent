require 'spec_helper'

describe 'datadog_agent::integrations::supervisord' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }

      conf_file = if agent_major_version == 5
                    '/etc/dd-agent/conf.d/supervisord.yaml'
                  else
                    "#{CONF_DIR}/supervisord.d/conf.yaml"
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
        it { is_expected.to contain_file(conf_file).with_content(%r{name: server0\s+host: localhost\s+port: 9001}) }
      end

      context 'with one supervisord' do
        context 'without processes' do
          let(:params) do
            {
              instances: [
                {
                  'servername' => 'server0',
                  'socket'     => 'unix://var/run/supervisor.sock',
                },
              ],
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{name: server0\s+socket: unix://var/run/supervisor.sock}) }
        end
        context 'with processes' do
          let(:params) do
            {
              instances: [
                {
                  'servername' => 'server0',
                  'socket'     => 'unix://var/run/supervisor.sock',
                  'proc_names' => ['java', 'apache2'],
                },
              ],
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{name: server0\s+socket: unix://var/run/supervisor.sock\s+proc_names:\s+- java\s+- apache2}) }
        end
      end

      context 'with multiple supervisord' do
        context 'without processes parameter array' do
          let(:params) do
            {
              instances: [
                {
                  'servername' => 'server0',
                  'socket' => 'unix://var/run/supervisor.sock',
                },
                {
                  'servername' => 'server1',
                  'hostname'   => 'localhost',
                  'port'       => '9001',
                },
              ],
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{name: server0\s+socket: unix://var/run/supervisor.sock}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{name: server1\s+host: localhost\s+port: 9001}) }
        end
        context 'with processes parameter array' do
          let(:params) do
            {
              instances: [
                {
                  'servername' => 'server0',
                  'socket'     => 'unix://var/run/supervisor.sock',
                  'proc_names' => ['webapp', 'nginx'],
                },
                {
                  'servername' => 'server1',
                  'hostname'   => 'localhost',
                  'port'       => '9001',
                  'proc_names' => ['java', 'apache2'],
                },
              ],
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{name: server0\s+socket: unix://var/run/supervisor.sock\s+proc_names:\s+- webapp\s+- nginx}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{name: server1\s+host: localhost\s+port: 9001\s+proc_names:\s+- java\s+- apache2}) }
        end
      end
    end
  end
end
