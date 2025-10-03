FROM datadog/docker-library:chef_kitchen_systemd_rocky_9

# Base packages needed for SSH access from kitchen
RUN yum clean all && \
    yum install -y sudo openssh-server openssh-clients which

# Generate supported SSH host keys (skip DSA which is removed in OpenSSH 9+)
RUN [ -f "/etc/ssh/ssh_host_rsa_key" ] || ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ''
RUN [ -f "/etc/ssh/ssh_host_ecdsa_key" ] || ssh-keygen -t ecdsa -b 521 -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN [ -f "/etc/ssh/ssh_host_ed25519_key" ] || ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''

# Create the kitchen user if missing (kept for parity with default kitchen-docker behavior)
RUN if ! getent passwd kitchen; then \
      useradd -d /home/kitchen -m -s /bin/bash -p '*' kitchen; \
    fi


