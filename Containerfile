ARG FEDORA_VERSION=44
FROM quay.io/fedora/fedora-bootc:${FEDORA_VERSION}

LABEL org.opencontainers.image.title="fedora-workspace"
LABEL org.opencontainers.image.description="Personal Fedora bootc system image"
LABEL containers.bootc="1"

RUN dnf5 install -y \
    bash-completion \
    curl \
    git \
    htop \
    jq \
    lsof \
    neovim \
    openssh-server \
    podman \
    rsync \
    sudo \
    tailscale \
    tmux \
    vim-enhanced \
    wget \
    zsh \
    && dnf5 clean all

RUN systemctl enable \
    sshd.service \
    NetworkManager.service

COPY system_files/ /

RUN bootc container lint
