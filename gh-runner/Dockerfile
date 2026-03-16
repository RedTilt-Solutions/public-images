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

# Node.js LTS for Pact JS/TS contract tests (@pact-foundation/pact, pact-cli)
ARG NODE_VERSION=24
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g @pact-foundation/pact-cli@latest

# Pact standalone CLI (pact-broker, pact-verifier, pact-mock-server, pact-stub-server)
ARG PACT_CLI_VERSION=v2.5.12
RUN mkdir -p /opt/pact-install \
    && cd /opt/pact-install \
    && curl -fsSL https://raw.githubusercontent.com/pact-foundation/pact-standalone/master/install.sh | PACT_CLI_VERSION=${PACT_CLI_VERSION} bash \
    && cp -r pact/bin/* /usr/local/bin/ \
    && cd / \
    && rm -rf /opt/pact-install

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
