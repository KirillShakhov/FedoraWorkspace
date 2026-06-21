# fedora-workspace

Personal Fedora bootc system image.

Desktop environment: KDE Plasma.

This repository builds:

- a bootable Fedora OCI image published to GitHub Container Registry;
- optional disk artifacts, such as `qcow2`, for targets that need an installable or importable disk.

## Architecture

```text
Containerfile
  -> GitHub Actions
  -> ghcr.io/<owner>/fedora-workspace:latest
  -> target machine
```

The target machine is not running inside a container. The OCI image is the transport format for the bootable operating system.

## First Setup

1. Create a new GitHub repository.
2. Copy these files into it.
3. Push to `main`.
4. Run the `build-container` workflow.
5. Optionally run the `build-disk` workflow to produce a `qcow2` disk.

The container image will be published as:

```text
ghcr.io/<owner>/fedora-workspace:latest
```

## Customize Packages

Edit `Containerfile`:

```Dockerfile
RUN dnf5 install -y \
    openssh-server \
    nano \
    zsh \
    && dnf5 clean all
```

The base image intentionally does not include deployment-specific agents such as `cloud-init` or `qemu-guest-agent`.

## DevOps Tooling

The base image includes a Fedora-packaged DevOps/development set:

- containers: `moby-engine` (`docker`), `docker-compose`, `docker-compose-switch`, `distrobox`;
- Kubernetes: `kubernetes-client` (`kubectl`), `helm`;
- infrastructure automation: `opentofu`, `ansible`;
- cloud/repositories: `gh`;
- host language runtimes and native build toolchain: `clang`, `cmake`, `gcc`, `gcc-c++`, `gdb`, `golang`, `lldb`, `ninja-build`, `nodejs`, `npm`, `python3`, `python3-pip`, `python3-virtualenv`;
- linting/data tools: `ShellCheck`, `yamllint`, `jq`, `yq`;
- security/crypto tools: `age`, `openssl`;
- diagnostics: `bind-utils`, `iproute`, `iputils`, `lsof`, `nmap`, `nmap-ncat`, `socat`, `tcpdump`, `traceroute`, `whois`;
- desktop/app runtime: `flatpak`;
- shell/workflow tools: `direnv`, `just`, `make`, `nano`, `ripgrep`, `tmux`, `tree`, `zsh`, `zstd`.

Nano is the default editor via `system_files/etc/profile.d/editor.sh` and the zsh skeleton config.

## Desktop

The image installs a focused KDE Plasma package set, enables `sddm.service`, and sets the default systemd target to `graphical.target`.

## Desktop IDEs

VS Code and IntelliJ IDEA Community are installed as Flatpaks after deployment, not baked into the base OS image. Run:

```bash
sudo install-flatpack-apps
```

That script adds Flathub as a system remote and installs:

- `com.visualstudio.code`
- `com.jetbrains.IntelliJ-IDEA-Community`

## Shell

Bash remains installed for scripts and system compatibility. New users default to zsh via `useradd -D -s /usr/bin/zsh`, and the default zsh theme/config is placed in `system_files/etc/skel/.zshrc`.

## User

The image creates a `kirill` user with zsh as the login shell and membership in `wheel` and `docker`.

No password is baked into the image. A public SSH key for `kirill` is stored in `system_files/home/kirill/.ssh/authorized_keys`.

For a public repository, keep private credentials out of this repo and provide sensitive access material at install/provisioning time:

- use an installer or target-specific provisioning to set the password;
- inject additional SSH keys from the deployment target;
- keep secrets in a private repo, password manager, or secret manager.

The `kirill` account cannot be used for password login until a password is provisioned.

## Git

Git is installed in the base image. The system-wide defaults live in `system_files/etc/gitconfig`.

## Deployment Targets

- Proxmox: see `deploy/proxmox/README.md`.
- Other QEMU/KVM hosts: use the `qcow2` artifact directly, or create a target-specific variant.
- Existing bootc system: switch to the image with `bootc switch`.
- Existing Fedora Atomic/rpm-ostree system: rebase using the matching signed or unsigned image flow for that system.
- Bare metal: build an installer or disk image and handle user creation through your chosen install/provisioning flow.

## Updating

After a new image is pushed:

```bash
sudo bootc upgrade
sudo systemctl reboot
```

To switch to another tag:

```bash
sudo bootc switch ghcr.io/<owner>/fedora-workspace:<tag>
sudo systemctl reboot
```

Rollback:

```bash
sudo bootc rollback
sudo systemctl reboot
```

## Notes

- The default `kirill` account is locked for password login until a password is provisioned.
- A public SSH key is baked into the image for `kirill`.
- Long-term identity should come from the target platform's provisioning path, installer, or your own private system files.
- The default SSH config disables password login.
- For private GHCR images, the running machine needs registry credentials before `bootc upgrade` can pull updates.
