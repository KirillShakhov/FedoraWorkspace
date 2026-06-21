ARG FEDORA_VERSION=44
FROM quay.io/fedora/fedora-bootc:${FEDORA_VERSION}

LABEL org.opencontainers.image.title="fedora-workspace"
LABEL org.opencontainers.image.description="Personal Fedora bootc system image"
LABEL containers.bootc="1"

RUN dnf5 install -y \
    ShellCheck \
    age \
    ansible \
    bash-completion \
    bind-utils \
    curl \
    direnv \
    docker-compose \
    docker-compose-switch \
    gh \
    git \
    git-lfs \
    golang \
    helm \
    htop \
    iproute \
    iputils \
    just \
    jq \
    kubernetes-client \
    lsof \
    make \
    moby-engine \
    nano \
    nmap \
    nmap-ncat \
    nodejs \
    npm \
    openssh-server \
    openssl \
    opentofu \
    python3 \
    python3-pip \
    python3-virtualenv \
    ripgrep \
    rsync \
    socat \
    sops \
    sudo \
    tailscale \
    tcpdump \
    tmux \
    traceroute \
    tree \
    unzip \
    wget \
    whois \
    yamllint \
    yq \
    zsh \
    zstd \
    && dnf5 clean all

RUN systemctl enable \
    docker.service \
    sshd.service \
    NetworkManager.service

RUN useradd -D -s /usr/bin/zsh

COPY system_files/ /

RUN bootc container lint
