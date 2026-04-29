FROM ubuntu:26.04

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
    && if id -u ubuntu >/dev/null 2>&1; then userdel -r ubuntu; fi \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*