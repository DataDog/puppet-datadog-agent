require 'spec_helper'

describe 'datadog_agent' do
  context 'unsupported operating system' do
    describe 'datadog_agent class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          osfamily:         'Solaris',
          operatingsystem:  'Nexenta'
        }
      end

      it do
        expect {
          should contain_package('module')
        }.to raise_error(Puppet::Error, /Unsupported operatingsystem: Nexenta/)
      end
    end
  end

  # Test all supported OSes
  context 'all supported operating systems' do
    ALL_OS.each do |operatingsystem|
      describe "datadog_agent class common actions on #{operatingsystem}" do
        let(:params) { { puppet_run_reports: true } }
        let(:facts) do
          {
            operatingsystem: operatingsystem,
            osfamily: DEBIAN_OS.include?(operatingsystem) ? 'debian' : 'redhat'
          }
        end

        it { should compile.with_all_deps }

        it { should contain_class('datadog_agent') }

        describe 'datadog_agent imports the default params' do
          it { should contain_class('datadog_agent::params') }
        end

        it { should contain_file('/etc/dd-agent') }
        it { should contain_file('/etc/dd-agent/datadog.conf') }

        it { should contain_class('datadog_agent::reports') }

        if DEBIAN_OS.include?(operatingsystem)
          it { should contain_class('datadog_agent::ubuntu') }
        elsif REDHAT_OS.include?(operatingsystem)
          it { should contain_class('datadog_agent::redhat') }
        end
      end
    end
  end

  context "with facts to tags set" do
    describe "make sure facts_array outputs a list of tags" do
      let(:params) { { puppet_run_reports: true, facts_to_tags: ['osfamily', 'facts_array']} }
      let(:facts) do
        {
          operatingsystem: 'CentOS',
          osfamily: 'redhat',
          facts_array: ['one', 'two', 'three']
        }
      end

        it { should contain_file('/etc/dd-agent/datadog.conf').with_content(/tags: osfamily:redhat, facts_array:one, facts_array:two, facts_array:three/) }
    end
  end

end
