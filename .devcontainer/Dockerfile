FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    less \
    openssh-client \
    python3 \
    python3-pip \
    sudo \
    unzip \
    vim \
    wget \
    ripgrep \
    yamllint \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Remove the default 'ubuntu' user if it exists to avoid conflicts with the devcontainer user
RUN if id -u ubuntu >/dev/null 2>&1; then userdel -r ubuntu; fi

# Install UV and Ansible-related tools
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh

# Install Ansible and related tools using UV
RUN uv pip install --system --break-system-packages --no-cache \
    ansible \
    ansible-lint \
    molecule \
    molecule-plugins[docker]
