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

# Node.js latest LTS for Pact contract tests (@pact-foundation/pact)
ARG NODE_VERSION=24
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g @pact-foundation/pact-cli@latest

# Go for Pact contract tests (github.com/pact-foundation/pact-go) — latest stable
ARG GO_VERSION=1.26.1
RUN ARCH="$(dpkg --print-architecture)" && \
    case "$ARCH" in \
        amd64) GO_ARCH="linux-amd64" ;; \
        arm64) GO_ARCH="linux-arm64" ;; \
        *) echo "Unsupported arch: $ARCH" && exit 1 ;; \
    esac && \
    curl -fsSL -o /tmp/go.tgz "https://go.dev/dl/go${GO_VERSION}.${GO_ARCH}.tar.gz" && \
    tar -C /usr/local -xzf /tmp/go.tgz && \
    rm /tmp/go.tgz
ENV PATH="/usr/local/go/bin:${PATH}"

# Java and Maven for Pact contract tests (pact-jvm) — latest LTS
ARG JAVA_VERSION=21
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-${JAVA_VERSION}-jdk-headless \
    maven \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/lib/jvm/java-${JAVA_VERSION}-openjdk-$(dpkg --print-architecture) /usr/lib/jvm/default-java
ENV JAVA_HOME=/usr/lib/jvm/default-java

# .NET SDK latest LTS for Pact contract tests (Pact.Net)
RUN curl -fsSL -o /tmp/packages-microsoft-prod.deb \
    https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb \
    && dpkg -i /tmp/packages-microsoft-prod.deb && rm /tmp/packages-microsoft-prod.deb \
    && apt-get update && apt-get install -y --no-install-recommends dotnet-sdk-10.0 \
    && rm -rf /var/lib/apt/lists/*

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
