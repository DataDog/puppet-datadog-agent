require 'spec_helper'

describe 'datadog_agent::integrations::logs' do
  context 'supported agents - v6' do
    let(:pre_condition) { "class {'::datadog_agent': agent_major_version => 6}" }

    conf_file = "#{CONF_DIR}/logs.yaml"

    context 'with default parameters' do
      it { is_expected.to compile }
    end

    context 'with parameters set' do
      let(:params) do
        {
          logs: [
            {
              'type' => 'file',
              'path' => 'apath.log',
            },
            {
              'type' => 'docker',
            },
          ],
        }
      end

      it { is_expected.to contain_file(conf_file).with_content(%r{logs:}) }
      it { is_expected.to contain_file(conf_file).with_content(%r{- type: file}) }
      it { is_expected.to contain_file(conf_file).with_content(%r{path: apath.log}) }
      it { is_expected.to contain_file(conf_file).with_content(%r{- type: docker}) }
    end
  end
end
