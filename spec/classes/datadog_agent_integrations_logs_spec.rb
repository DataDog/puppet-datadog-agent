require 'spec_helper'

describe 'datadog_agent::integrations::logs' do
  context 'supported agents - v6' do    
    let(:pre_condition) { "class {'::datadog_agent': agent5_enable => false}" }
    let(:conf_file) { "#{CONF_DIR6}/logs.yaml" }

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
