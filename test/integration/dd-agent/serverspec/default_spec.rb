require_relative 'spec_helper'

describe 'datadog_agent' do
  describe file('/etc/datadog-agent') do
    it { is_expected.to be_directory }
  end

  describe service('datadog-agent') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end
end
