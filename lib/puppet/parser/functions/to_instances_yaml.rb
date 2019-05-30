require 'yaml'

module Puppet::Parser::Functions
    newfunction(:to_instances_yaml, :type => :rvalue) do |args|
        init_config = args[0]
        instances = args[1]
        logs = args[2]
        default_values = {
            'init_config'  => init_config.is_a?(String) ? nil: init_config,
            'instances' => instances
        }
        if !logs.nil? && !logs.empty? then
          default_values.merge!({'logs' => logs})
        end
        YAML::dump(default_values)
    end
end
