FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

ARG SSH_USER=sshuser
ARG SSH_UID=1001
ARG SSH_PASSWORD=sshpassword

# Optional: export them at runtime too
ENV SSH_USER=$SSH_USER SSH_UID=$SSH_UID

# Create user from build args
RUN useradd -rm -d /home/${SSH_USER} -s /bin/bash -g root -G sudo -u ${SSH_UID} ${SSH_USER} && \
    echo "${SSH_USER}:${SSH_PASSWORD}" | chpasswd

# Crate directory for SSH keys
RUN mkdir -p /home/${SSH_USER}/.ssh && \
    chown ${SSH_USER}:root /home/${SSH_USER}/.ssh && \
    chmod 700 /home/${SSH_USER}/.ssh

EXPOSE 22

# Install OpenSSH server
RUN apt-get update && \
    apt-get install -y openssh-server sudo && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /var/run/sshd

# Configure SSH
# RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
#     sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
#     sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
# RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

CMD ["/usr/sbin/sshd", "-D"]
