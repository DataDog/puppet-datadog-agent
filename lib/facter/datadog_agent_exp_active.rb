Facter.add(:datadog_agent_exp_active) do
  confine kernel: 'Linux'
  setcode do
    # Prefer systemd when available
    if Facter::Util::Resolution.which('systemctl')
      return true if system('systemctl is-active --quiet datadog-agent-exp')
    end

    # SysV-compatible service command
    if Facter::Util::Resolution.which('service')
      return true if system('service datadog-agent-exp status >/dev/null 2>&1')
    end

    # Fallback: look for the experiment agent process by its binary path substring
    if Facter::Util::Resolution.which('pgrep')
      return true if system('pgrep -f datadog-packages/datadog-agent/experiment/bin/agent/agent >/dev/null 2>&1')
    end

    false
  end
end


