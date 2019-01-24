require 'spec_helper'

describe "datadog_agent::integration" do
  context 'supported agents - v5 and v6' do
    agents = { '5' => true, '6' => false }
    agents.each do |_, enabled|
      let(:pre_condition) { "class {'::datadog_agent': agent5_enable => #{enabled}}" }
      if enabled
        let(:conf_file) { '/etc/dd-agent/conf.d/test.yaml' }
      else
        let(:conf_dir) { '/etc/datadog-agent/conf.d/test.d' }
        let(:conf_file) { "#{conf_dir}/conf.yaml" }
      end

      let (:title) { "test" }
      let(:facts) do
        {
          operatingsystem: 'CentOS',
          osfamily: 'redhat'
        }
      end
      let (:params) {{
          :instances => [
              { 'one' => "two" }
          ]
      }}


      it { should compile }
      if enabled
        it { should contain_file("#{conf_dir}").that_comes_before("File[#{conf_file}]") }
      end
      it { should contain_file("#{conf_file}").with_content(/init_config: /) }
      gem_spec = Gem.loaded_specs['puppet']
      if gem_spec.version >= Gem::Version.new('4.0.0')
        it { should contain_file("#{conf_file}").with_content(/---\ninit_config: \ninstances:\n- one: two\n/) }
      else
        it { should contain_file("#{conf_file}").with_content(/--- \n  init_config: \n  instances: \n    - one: two/) }
      end
      it { should contain_file("#{conf_file}").that_notifies("Service[datadog-agent]") }
    end
  end
end
