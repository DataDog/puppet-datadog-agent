from checks import AgentCheck
from time import time
import yaml         #requires PyYAML

class puppetCheck(AgentCheck):
  def check(self, instance):
    with open("/var/lib/puppet/state/last_run_summary.yaml", "r") as summary:
        file_data = yaml.load(summary)
        date = file_data["time"]["last_run"]
        failures = file_data["events"]["failure"]
        age_seconds = time() - date

        version = file_data["version"]["puppet"]
        tag = "puppet_version:" + version

        self.gauge("puppet.last_run_age_seconds",age_seconds,tags=[tag])
        self.gauge("puppet.last_run_num_failures",failures,tags=[tag])
