require 'spec_helper'

describe 'datadog_agent' do

  context 'Debian based supported operating systems' do
    ['Ubuntu', 'Debian'].each do |operatingsystem|
      describe "datadog_agent class without any parameters on #{operatingsystem}" do
        let(:params) {{ }}
        let(:facts) {{
          :operatingsystem => operatingsystem,
        }}

        it { should contain_class('datadog_agent::ubuntu') }
      end
    end
  end

  context 'Yum based supported operating systems' do
      ['RedHat', 'CentOS', 'Fedora', 'Amazon', 'Scientific'].each do |operatingsystem|
      describe "datadog_agent class without any parameters on #{operatingsystem}" do
        let(:params) {{ }}
        let(:facts) {{
          :operatingsystem => operatingsystem,
        }}

        it { should contain_class('datadog_agent::redhat') }
      end
    end
  end
  context 'unsupported operating system' do
    describe 'datadog_agent class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { should contain_package('module') }.to raise_error(Puppet::Error, /Unsupported operatingsystem: Nexenta/) }
    end
  end
end
