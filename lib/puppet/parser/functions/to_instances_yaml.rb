require 'yaml'

module Puppet::Parser::Functions
    newfunction(:to_instances_yaml, :type => :rvalue) do |args|
        ruby_data = args[0]
        default_values = {
            :init_config  => nil,
            :instances => ruby_data
        }
        YAML::dump(default_values)
    end
end
