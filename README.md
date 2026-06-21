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
3. Replace the SSH key in `disk_config/config.toml`, or remove the baked `admin` user and rely on your target platform's provisioning.
4. Push to `main`.
5. Run the `build-container` workflow.
6. Optionally run the `build-disk` workflow to produce a `qcow2` disk.

The container image will be published as:

```text
ghcr.io/<owner>/fedora-workspace:latest
```

## Customize Packages

Edit `Containerfile`:

```Dockerfile
RUN dnf5 install -y \
    qemu-guest-agent \
    cloud-init \
    openssh-server \
    neovim \
    zsh \
    && dnf5 clean all
```

Keep `cloud-init` and `openssh-server` if you want cloud or VM provisioning. Keep `qemu-guest-agent` when this image will run under QEMU/KVM environments such as Proxmox, libvirt, or plain QEMU.

## Deployment Targets

- Proxmox: see `deploy/proxmox/README.md`.
- Other QEMU/KVM hosts: use the `qcow2` artifact directly.
- Existing bootc system: switch to the image with `bootc switch`.
- Existing Fedora Atomic/rpm-ostree system: rebase using the matching signed or unsigned image flow for that system.
- Bare metal: build an installer or disk image with image-builder/bootc-image-builder and install it to the target disk.

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

- `disk_config/config.toml` is for generated disk images. It currently creates an SSH-key-only `admin` user as a fallback.
- Long-term identity should come from the target platform's provisioning path, not hardcoded passwords.
- The default SSH config disables password login.
- For private GHCR images, the running machine needs registry credentials before `bootc upgrade` can pull updates.
