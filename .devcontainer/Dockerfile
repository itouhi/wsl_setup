FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    less \
    sudo \
    unzip \
    vim \
    wget \
    ripgrep \
    && if id -u ubuntu >/dev/null 2>&1; then userdel -r ubuntu; fi \
    && curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*