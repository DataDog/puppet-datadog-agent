facter.add('apt_agent6_beta_repo') do
  setcode do
    file.exist? '/etc/apt/sources.list.d/datadog-beta.list'
  end
end
