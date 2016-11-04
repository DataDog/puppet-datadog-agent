require 'spec_helper'

describe 'datadog_agent::ubuntu::update_repo' do
  let(:facts) do
    {
      osfamily: 'debian',
      operatingsystem: 'Ubuntu'
    }
  end

  it do
    contain_file('/etc/apt/sources.list.d/datadog.list')\
      .with_content(%r{deb\s+https://apt.datadoghq.com/\s+stable\s+main})
  end

  # it should install the mirror
  it { should contain_exec('datadog_key') }
  it do
    should contain_file('/etc/apt/sources.list.d/datadog.list')\
      .that_notifies('Exec[datadog_apt-get_update]')
  end
  it { should contain_exec('datadog_apt-get_update') }

  # it should install the packages
  it do
    should contain_package('apt-transport-https')\
      .that_comes_before('File[/etc/apt/sources.list.d/datadog.list]')
  end
end
