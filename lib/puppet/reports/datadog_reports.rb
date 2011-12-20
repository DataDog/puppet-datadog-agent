require 'puppet'
require 'yaml'

begin
  require 'dogapi'
rescue LoadError => e
  Puppet.info "You need the `dogapi` gem to use the DataDog report"
end

Puppet::Reports.register_report(:datadog_reports) do

  configfile = "/etc/dd-agent/datadog.yaml"
  raise(Puppet::ParseError, "DataDog report config file #{configfile} not readable") unless File.exist?(configfile)
  config = YAML.load_file(configfile)
  API_KEY = config[:datadog_api_key]

  desc <<-DESC
  Send notification of metrics to DataDog
  DESC

  def process
    @summary = self.summary

    if defined?(self.status)
      @status = self.status
    else
      @status = 'Upgrade your PuppetMaster to > 2.6.8'
    end

    Puppet.debug "Sending metrics for #{@msg_host} to DataDog"
    @dog = Dogapi::Client.new(API_KEY)
    self.metrics.each { |metric,data|
      data.values.each { |val|
        name = "puppet.#{val[1].gsub(/ /, '_')}.#{metric}".downcase
        value = val[2]
        @dog.emit_point("#{name}", value, :host => "#{@msg_host}")
      }
    }

    Puppet.debug "Sending events for #{@msg_host} to DataDog"
    output = []
    self.logs.each do |log|
      output << log
    end
    @dog.emit_event(Dogapi::Event.new(output.join("\n"), :msg_title => "Puppet run on #{@msg_host} (status: #{@status})", :event_type => 'Puppet'))
  end
end
