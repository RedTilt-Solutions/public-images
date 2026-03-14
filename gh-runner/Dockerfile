FROM ubuntu:26.04

ARG RUNNER_VERSION=2.332.0
ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_ALLOW_RUNASROOT=1

WORKDIR /actions-runner

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    git \
    sudo \
    unzip \
    tar \
    bash \
    docker.io \
    libicu-dev \
    libicu78 \
 && rm -rf /var/lib/apt/lists/*

 RUN ARCH="$(dpkg --print-architecture)" && \
 case "$ARCH" in \
   amd64) RUNNER_ARCH="x64" ;; \
   arm64) RUNNER_ARCH="arm64" ;; \
   armhf) RUNNER_ARCH="arm" ;; \
   *) echo "Unsupported arch: $ARCH" && exit 1 ;; \
 esac && \
 curl -fsSL -o actions-runner.tar.gz \
   "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz" && \
 tar xzf actions-runner.tar.gz && \
 rm -f actions-runner.tar.gz

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
