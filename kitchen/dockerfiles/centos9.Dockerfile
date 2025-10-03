FROM datadog/docker-library:chef_kitchen_systemd_centos_9

# Base packages needed for SSH access from kitchen
RUN yum clean all && \
    yum install -y sudo openssh-server openssh-clients which

# Generate supported SSH host keys (skip DSA which is removed in OpenSSH 9+)
RUN [ -f "/etc/ssh/ssh_host_rsa_key" ] || ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ''
RUN [ -f "/etc/ssh/ssh_host_ecdsa_key" ] || ssh-keygen -t ecdsa -b 521 -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN [ -f "/etc/ssh/ssh_host_ed25519_key" ] || ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''

# Inject Kitchen's public key for SSH access (driver provides insecure_key.pub in build context)
ADD insecure_key.pub /tmp/insecure_key.pub
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh && \
    touch /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys && \
    cat /tmp/insecure_key.pub >> /root/.ssh/authorized_keys

# Create the kitchen user if missing (kept for parity with default kitchen-docker behavior)
RUN if ! getent passwd kitchen; then \
      useradd -d /home/kitchen -m -s /bin/bash -p '*' kitchen; \
    fi

# Allow SSH key login for the kitchen user as well
RUN mkdir -p /home/kitchen/.ssh && chmod 700 /home/kitchen/.ssh && \
    touch /home/kitchen/.ssh/authorized_keys && chmod 600 /home/kitchen/.ssh/authorized_keys && \
    cat /tmp/insecure_key.pub >> /home/kitchen/.ssh/authorized_keys && \
    chown -R kitchen:kitchen /home/kitchen/.ssh


