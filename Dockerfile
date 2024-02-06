FROM ubuntu:22.04

ARG RUNNER_VERSION

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get upgrade -y && useradd -m docker

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

RUN export arch=`[ "$(uname -m)" = 'x86_64' ] && echo 'x64' || [ "$(uname -m)" = 'aarch64' ] && echo 'arm64' || echo 'arm'` \
    && cd /home/docker && mkdir actions-runner && cd actions-runner \
    && sh -c "curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${arch}-${RUNNER_VERSION}.tar.gz" \
    && sh -c "tar xzf actions-runner-linux-${arch}-${RUNNER_VERSION}.tar.gz" \
    && sh -c "rm actions-runner-linux-${arch}-${RUNNER_VERSION}.tar.gz"

RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

COPY start.sh start.sh

USER docker

ENTRYPOINT ["./start.sh"]
