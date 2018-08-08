facter.add('apt_agent6_repo') do
  setcode do
    file.exist? '/etc/apt/sources.list.d/datadog-6.list'
  end
end
