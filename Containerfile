ARG FEDORA_VERSION=44
FROM quay.io/fedora/fedora-bootc:${FEDORA_VERSION}

LABEL org.opencontainers.image.title="fedora-workspace"
LABEL org.opencontainers.image.description="Personal Fedora bootc system image"
LABEL containers.bootc="1"

# KDE Plasma session, display manager, graphics, audio, and hardware integration.
RUN dnf5 install -y --setopt=install_weak_deps=False \
    NetworkManager \
    NetworkManager-bluetooth \
    NetworkManager-wifi \
    alsa-utils \
    bluez \
    bluedevil \
    breeze-cursor-theme \
    breeze-icon-theme \
    google-noto-emoji-fonts \
    google-noto-sans-fonts \
    kde-settings \
    kwin \
    mesa-dri-drivers \
    mesa-vulkan-drivers \
    pipewire \
    plasma-desktop \
    plasma-nm \
    plasma-pa \
    plasma-workspace \
    polkit-kde \
    powerdevil \
    sddm \
    sddm-wayland-plasma \
    wireplumber \
    xdg-desktop-portal \
    xdg-desktop-portal-kde \
    xorg-x11-server-Xwayland \
    && dnf5 clean all

# Desktop applications that are useful on the host system.
RUN dnf5 install -y --setopt=install_weak_deps=False \
    ark \
    dolphin \
    flatpak \
    flatpak-kcm \
    konsole \
    plasma-systemmonitor \
    && dnf5 clean all

# Base CLI, networking, diagnostics, editor, shell, and SSH tools.
RUN dnf5 install -y --setopt=install_weak_deps=False \
    bash-completion \
    bind-utils \
    curl \
    git \
    git-lfs \
    htop \
    iproute \
    iputils \
    jq \
    lsof \
    make \
    nano \
    nmap \
    nmap-ncat \
    openssh-server \
    openssl \
    ripgrep \
    rsync \
    socat \
    sudo \
    tailscale \
    tcpdump \
    tmux \
    traceroute \
    tree \
    unzip \
    wget \
    whois \
    yq \
    zsh \
    zstd \
    && dnf5 clean all

# Docker-first container stack and Distrobox.
RUN dnf5 install -y --setopt=install_weak_deps=False \
    docker-buildx \
    docker-compose \
    docker-compose-switch \
    distrobox \
    moby-engine \
    && dnf5 clean all

# DevOps and infrastructure tools.
RUN dnf5 install -y --setopt=install_weak_deps=False \
    ShellCheck \
    age \
    ansible \
    direnv \
    gh \
    helm \
    just \
    kubernetes-client \
    opentofu \
    yamllint \
    && dnf5 clean all

# Host language runtimes and native build toolchain.
RUN dnf5 install -y --setopt=install_weak_deps=False \
    clang \
    cmake \
    gcc \
    gcc-c++ \
    gdb \
    golang \
    lldb \
    ninja-build \
    nodejs \
    npm \
    python3 \
    python3-pip \
    python3-virtualenv \
    && dnf5 clean all

RUN systemctl enable \
    docker.service \
    sshd.service \
    NetworkManager.service \
    sddm.service

RUN systemctl set-default graphical.target

COPY system_files/etc/ /etc/
COPY system_files/usr/ /usr/

RUN useradd -D -s /usr/bin/zsh

RUN mkdir -p /var/home \
    && useradd \
    --no-create-home \
    --home-dir /var/home/kirill \
    --shell /usr/bin/zsh \
    --groups wheel,docker \
    kirill \
    && usermod --password '$6$APaVAsfSqyuEw8P6$IIWn.H7awEgwF3jvY36GdpxsGqkWM.nv2TNi/GDcZR/K3Wp/JUsAuPxWxgGYTDuaz1w2/f1mqfofngt5Oag6l/' kirill \
    && chage -d 0 kirill

RUN systemd-tmpfiles --create fedora-workspace.conf

RUN rm -rf \
    /run/dnf \
    /run/sddm \
    /run/selinux-policy \
    /tmp/* \
    /var/cache/libX11 \
    /var/cache/libdnf5 \
    /var/cache/ldconfig/aux-cache \
    /var/cache/swcatalog \
    /var/cache/tailscale \
    /var/lib/AccountsService \
    /var/lib/alsa \
    /var/lib/authselect \
    /var/lib/authselect/checksum \
    /var/lib/dnf/repos/*/countme \
    /var/lib/dnf/repos \
    /var/lib/dnf/system-repo.lock \
    /var/lib/flatpak \
    /var/lib/geoclue \
    /var/lib/rpm-state \
    /var/lib/tailscale \
    /var/log/dnf5.log*

RUN bootc container lint
