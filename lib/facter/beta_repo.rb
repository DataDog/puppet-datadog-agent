Facter.add('apt_agent6_beta_repo') do
  setcode do
    File.exist? '/etc/apt/sources.list.d/datadog-beta.list'
  end
end
