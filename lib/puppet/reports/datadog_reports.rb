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
    @msg_host = self.host

    event_title = ''
    alert_type = ''
    event_priority = ''

    if defined?(self.status)
      # for puppet log format 2 and above
      @status = self.status
      if @status == 'failed'
        event_title = "Puppet failed on #{@msg_host}"
        alert_type = "error"
        event_priority = "normal"
      elsif @status == 'changed'
        event_title = "Puppet changed resources on #{@msg_host}"
        alert_type = "success"
        event_priority = "low"
      elsif @status == "unchanged"
        event_title = "Puppet ran on, and left #{@msg_host} unchanged"
        alert_type = "success"
        event_priority = "low"
      else 
        event_title = "Puppet ran on #{@msg_host}"
        alert_type = "success"
        event_priority = "low"
      end

    else
      # for puppet log format 1
      event_title = "Puppet ran on #{@msg_host}"
      event_priority = "low"
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
    @dog.emit_event(Dogapi::Event.new(event_data,
                                      :msg_title => event_title,
                                      :event_type => 'config_management.run',
                                      :event_object => @msg_host,
                                      :alert_type => alert_type,
                                      :priority => event_priority,
                                      :source_type_name => 'puppet'
                                      ), :host => @msg_host)
  end
end
