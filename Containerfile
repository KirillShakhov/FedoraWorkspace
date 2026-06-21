ARG FEDORA_VERSION=44
FROM quay.io/fedora/fedora-bootc:${FEDORA_VERSION}

LABEL org.opencontainers.image.title="fedora-workspace"
LABEL org.opencontainers.image.description="Personal Fedora bootc system image"
LABEL containers.bootc="1"

RUN dnf5 group install -y kde-desktop-environment \
    && dnf5 install -y sddm \
    && dnf5 clean all

RUN dnf5 install -y \
    ShellCheck \
    age \
    ansible \
    bash-completion \
    bind-utils \
    curl \
    direnv \
    distrobox \
    docker-compose \
    docker-compose-switch \
    flatpak \
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
    NetworkManager.service \
    sddm.service

RUN systemctl set-default graphical.target

RUN useradd -D -s /usr/bin/zsh

RUN useradd \
    --create-home \
    --shell /usr/bin/zsh \
    --groups wheel,docker \
    kirill \
    && passwd -l kirill

COPY system_files/ /

RUN chown -R kirill:kirill /home/kirill/.ssh \
    && chmod 700 /home/kirill/.ssh \
    && chmod 600 /home/kirill/.ssh/authorized_keys

RUN bootc container lint
