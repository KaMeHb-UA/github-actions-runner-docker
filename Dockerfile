FROM ubuntu:22.04

ARG RUNNER_VERSION

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get upgrade -y && useradd -m docker

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

RUN export arch=`bash -c 'if [ "$(uname -m)" = x86_64 ]; then echo x64; elif [ "$(uname -m)" = aarch64 ]; then echo arm64; else echo arm; fi'` \
    && cd /home/docker && mkdir actions-runner && cd actions-runner \
    && sh -c "curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${arch}-${RUNNER_VERSION}.tar.gz" \
    && sh -c "tar xzf actions-runner-linux-${arch}-${RUNNER_VERSION}.tar.gz" \
    && sh -c "rm actions-runner-linux-${arch}-${RUNNER_VERSION}.tar.gz"

RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# Helpful utils
RUN apt-get install -y --no-install-recommends openssh-client ca-certificates curl wget

# Docker
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update -y \
    && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

COPY start.sh start.sh

USER docker

ENTRYPOINT ["./start.sh"]
