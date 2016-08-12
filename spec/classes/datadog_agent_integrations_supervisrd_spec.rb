require 'spec_helper'

describe 'datadog_agent::integrations::supervisord' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/supervisord.yaml" }

  it { should compile.with_all_deps }
  it { should contain_file(conf_file).with(
    owner: dd_user,
    group: dd_group,
    mode: '0600',
  )}
  it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
  it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

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
