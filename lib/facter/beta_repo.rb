Facter.add('apt_agent6_beta_repo') do
  setcode do
    File.exist? '/etc/apt/sources.list.d/datadog-beta.list'
  end
end

Facter.add('apt_agent6_repo') do
  setcode do
    File.exist? '/etc/apt/sources.list.d/datadog6.list'
  end
end

Facter.add('apt_agent5_legacy_repo') do
  setcode do
    File.exist? '/etc/apt/sources.list.d/datadog-beta.list'
  end
end

Facter.add('apt_agent6_repo') do
  setcode do
    File.exist? '/etc/apt/sources.list.d/datadog6.list'
  end
end
