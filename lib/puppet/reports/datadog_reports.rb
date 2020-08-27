require 'puppet'
require 'yaml'

begin
  require 'dogapi'
rescue LoadError
  Puppet.info 'You need the `dogapi` gem to use the Datadog report (run puppet with puppet_run_reports on your master)'
end

Puppet::Reports.register_report(:datadog_reports) do
  configfile = '/etc/datadog-agent/datadog-reports.yaml'
  raise(Puppet::ParseError, "Datadog report config file #{configfile} not readable") unless File.readable?(configfile)
  config = YAML.load_file(configfile)
  API_KEY = config[:datadog_api_key]
  API_URL = config[:api_url]
  REPORT_FACT_TAGS = config[:report_fact_tags] || []

  if ENV['DD_PROXY_HTTP'].nil?
    ENV['DD_PROXY_HTTP'] = config[:proxy_http]
  end
  if ENV['DD_PROXY_HTTPS'].nil?
    ENV['DD_PROXY_HTTPS'] = config[:proxy_https]
  end

  # if need be initialize the regex
  if !config[:hostname_extraction_regex].nil?
    begin
      HOSTNAME_EXTRACTION_REGEX = Regexp.new config[:hostname_extraction_regex]
    rescue
      raise(Puppet::ParseError, "Invalid hostname_extraction_regex #{HOSTNAME_REGEX}")
    end
    unless HOSTNAME_EXTRACTION_REGEX.named_captures.key? 'hostname'
      raise(Puppet::ParseError, "hostname_extraction_regex doesn't include a match group named 'hostname': #{HOSTNAME_REGEX}")
    end
  else
    HOSTNAME_EXTRACTION_REGEX = nil
  end

  desc <<-DESC
  Send notification of metrics to Datadog
  DESC

  def pluralize(number, noun)
    if number == 0
      "no #{noun}"
    elsif number < 1
      "less than 1 #{noun}"
    elsif number == 1
      "1 #{noun}"
    else
      "#{number.round} #{noun}s"
    end
  rescue
    "#{number} #{noun}(s)"
  end

  def process
    # Here we have access to methods in Puppet::Transaction::Report
    # https://puppet.com/docs/puppet/latest/format_report.html#puppet::transaction::report
    @summary = summary
    @msg_host = host
    unless HOSTNAME_EXTRACTION_REGEX.nil?
      m = @msg_host.match(HOSTNAME_EXTRACTION_REGEX)
      if !m.nil? && !m[:hostname].nil?
        @msg_host = m[:hostname]
      end
    end
    Puppet.info "Processing reports for #{@msg_host}"

    event_title = ''
    alert_type = ''
    event_priority = 'low'
    event_data = ''

    if defined?(status)
      # for puppet log format 2 and above
      @status = status
      if @status == 'failed'
        event_title = "Puppet failed on #{@msg_host}"
        alert_type = 'error'
        event_priority = 'normal'
      elsif @status == 'changed'
        event_title = "Puppet changed resources on #{@msg_host}"
        alert_type = 'success'
        event_priority = 'normal'
      elsif @status == 'unchanged'
        event_title = "Puppet ran on, and left #{@msg_host} unchanged"
        alert_type = 'success'
      else
        event_title = "Puppet ran on #{@msg_host}"
        alert_type = 'success'
      end

    else
      # for puppet log format 1
      event_title = "Puppet ran on #{@msg_host}"
    end

    # Extract statuses
    total_resource_count = resource_statuses.length
    changed_resources    = resource_statuses.values.select { |s| s.changed }
    failed_resources     = resource_statuses.values.select { |s| s.failed }

    # Little insert if we know the config
    config_version_blurb = defined?(configuration_version) ? "applied version #{configuration_version} and" : ''

    event_data << "Puppet #{config_version_blurb} changed #{pluralize(changed_resources.length, 'resource')} out of #{total_resource_count}."

    # List changed resources
    unless changed_resources.empty?
      event_data << "\nThe resources that changed are:\n@@@\n"
      changed_resources.each { |s| event_data << "#{s.title} in #{s.file}:#{s.line}\n" }
      event_data << "\n@@@\n"
    end

    # List failed resources
    unless failed_resources.empty?
      event_data << "\nThe resources that failed are:\n@@@\n"
      failed_resources.each { |s| event_data << "#{s.title} in #{s.file}:#{s.line}\n" }
      event_data << "\n@@@\n"
    end

    # instantiate DogAPI client
    @dog = Dogapi::Client.new(API_KEY, nil, @msg_host, nil, nil, nil, API_URL)

    Puppet.debug "Sending metrics for #{@msg_host} to Datadog"
    @dog.batch_metrics do
      metrics.each do |metric, data|
        data.values.each do |val|
          name = "puppet.#{val[1].tr(' ', '_')}.#{metric}".downcase
          value = val[2]
          @dog.emit_point(name.to_s, value, host: @msg_host.to_s)
        end
      end
    end

    facts = Puppet::Node::Facts.indirection.find(host).values
    dog_tags = REPORT_FACT_TAGS.map { |name| "#{name}:#{facts.dig(*name.split('.'))}" }

    Puppet.debug "Sending events for #{@msg_host} to Datadog"
    @dog.emit_event(Dogapi::Event.new(event_data,
                                      msg_title: event_title,
                                      event_type: 'config_management.run',
                                      event_object: @msg_host,
                                      alert_type: alert_type,
                                      priority: event_priority,
                                      source_type_name: 'puppet',
                                      tags: dog_tags),
                    host: @msg_host)
  end
end
