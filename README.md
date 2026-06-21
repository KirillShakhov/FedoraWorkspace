# fedora-workspace

Personal Fedora bootc system image.

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

- containers: `moby-engine` (`docker`), `docker-compose`, `docker-compose-switch`;
- Kubernetes: `kubernetes-client` (`kubectl`), `helm`;
- infrastructure automation: `opentofu`, `ansible`;
- cloud/repositories: `gh`;
- languages/runtime tools for scripting: `golang`, `nodejs`, `npm`, `python3`, `python3-pip`, `python3-virtualenv`;
- linting/data tools: `ShellCheck`, `yamllint`, `jq`, `yq`;
- security/secrets: `age`, `sops`, `openssl`;
- diagnostics: `bind-utils`, `iproute`, `iputils`, `lsof`, `nmap`, `nmap-ncat`, `socat`, `tcpdump`, `traceroute`, `whois`;
- shell/workflow tools: `direnv`, `just`, `make`, `nano`, `ripgrep`, `tmux`, `tree`, `zsh`, `zstd`.

Nano is the default editor via `system_files/etc/profile.d/editor.sh` and the zsh skeleton config.

## Shell

Bash remains installed for scripts and system compatibility. New users default to zsh via `useradd -D -s /usr/bin/zsh`, and the default zsh theme/config is placed in `system_files/etc/skel/.zshrc`.

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

- No default user is baked into the image.
- No SSH key is baked into the image.
- Long-term identity should come from the target platform's provisioning path, installer, or your own system files.
- The default SSH config disables password login.
- For private GHCR images, the running machine needs registry credentials before `bootc upgrade` can pull updates.
