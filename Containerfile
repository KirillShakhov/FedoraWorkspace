ARG FEDORA_VERSION=44
FROM quay.io/fedora/fedora-bootc:${FEDORA_VERSION}

LABEL org.opencontainers.image.title="fedora-workspace"
LABEL org.opencontainers.image.description="Personal Fedora bootc system image"
LABEL containers.bootc="1"

RUN dnf5 install -y \
    bash-completion \
    cloud-init \
    curl \
    git \
    htop \
    jq \
    lsof \
    neovim \
    openssh-server \
    podman \
    qemu-guest-agent \
    rsync \
    sudo \
    tailscale \
    tmux \
    vim-enhanced \
    wget \
    zsh \
    && dnf5 clean all

# Enable baseline services that are useful on VMs and bare-metal installs.
# cloud-init is inert unless a supported datasource is attached.
RUN systemctl enable \
    cloud-init-local.service \
    cloud-init.service \
    cloud-config.service \
    cloud-final.service \
    qemu-guest-agent.service \
    sshd.service \
    NetworkManager.service

COPY system_files/ /

RUN bootc container lint
