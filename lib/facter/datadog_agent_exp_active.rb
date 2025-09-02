Facter.add(:datadog_agent_exp_active) do
  confine kernel: 'Linux'
  setcode do
    active = false

    # Determine via service manager when available
    if Facter::Util::Resolution.which('systemctl')
      active = system('systemctl is-active --quiet datadog-agent-exp')
    elsif Facter::Util::Resolution.which('service')
      active = system('service datadog-agent-exp status >/dev/null 2>&1')
    else
      # Fallback: look for the experiment agent binary as the running command (exact path prefix)
      if Facter::Util::Resolution.which('pgrep')
        active = system('pgrep -f "^/opt/datadog-packages/datadog-agent/experiment/bin/agent/agent( |$)" >/dev/null 2>&1')
      end
    end

    active
  end
end


