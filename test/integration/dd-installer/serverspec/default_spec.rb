require_relative 'spec_helper'

describe 'datadog_installer' do
  describe file('/opt/datadog-packages') do
    it { is_expected.to be_directory }
  end

  describe package('datadog-installer') do
    it { is_expected.to be_installed }
  end

  describe command('/usr/bin/datadog-installer is-installed datadog-apm-library-java') do
    # Installed, exit code should be 0
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe command('/usr/bin/datadog-installer is-installed datadog-apm-library-dotnet') do
    # Not installed, exit code should be 10
    its(:exit_status) { is_expected.to eq 10 }
  end
end
