require_relative 'spec_helper'

describe 'datadog_agent' do
  describe file('/etc/datadog-agent') do
    it { is_expected.to be_directory }
  end

  describe service('datadog-agent') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  describe command('rpm -q gpg-pubkey-4172a230-55dd14f6'), if: os[:family] == 'redhat' do
    its(:stdout) { is_expected.to match 'package gpg-pubkey-4172a230-55dd14f6 is not installed' }
    its(:exit_status) { is_expected.to eq 1 }
  end

  describe command('rpm -q gpg-pubkey-4172a230-55dd14f6'), if: os[:family] == 'opensuse' do
    its(:stdout) { is_expected.to match 'package gpg-pubkey-4172a230-55dd14f6 is not installed' }
    its(:exit_status) { is_expected.to eq 1 }
  end
end
