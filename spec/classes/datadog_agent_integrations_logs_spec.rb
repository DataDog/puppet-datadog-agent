require 'spec_helper'

describe 'datadog_agent::integrations::logs' do
  context 'supported agents - v6' do    
    let(:pre_condition) { "class {'::datadog_agent': agent5_enable => false}" }
    let(:facts) {{
      operatingsystem: 'Ubuntu',
    }}
    let(:conf_dir) { '/etc/datadog-agent/conf.d' }
    let(:dd_user) { 'dd-agent' }
    let(:dd_group) { 'root' }
    let(:dd_package) { 'datadog-agent' }
    let(:dd_service) { 'datadog-agent' }
    let(:conf_file) { "#{conf_dir}/logs.yaml" }

    context 'with default parameters' do
      it { should compile }
    end

    context 'with parameters set' do
      let(:params) {{
        logs: [
          {
            'type' => 'file',
            'path' => 'apath.log',
          },
          {
            'type' => 'docker',
          },
        ],
      }}
      it { should contain_file(conf_file).with_content(%r{logs:}) }
      it { should contain_file(conf_file).with_content(%r{- type: file}) }
      it { should contain_file(conf_file).with_content(%r{path: apath.log}) }
      it { should contain_file(conf_file).with_content(%r{- type: docker}) }
    end
  end
end
