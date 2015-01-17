require 'spec_helper'

describe 'datadog_agent::integrations::solr' do
  context 'with old-style paramaters' do
    let(:params){{
      :hostname => 'localhost',
      :port => 7199,
      :username => 'datadog',
      :password => 'yodawg',
      :java_bin_path => '/usr/bin/java7',
      :trust_store_path => '/etc/java/keychain.pem',
      :trust_store_password => 'javasecure'
    }}

    it { should contain_class('datadog_agent::integrations::solr') }

    it do
      should contain_file('/etc/dd-agent/conf.d/solr.yaml')
    end

  end

end
