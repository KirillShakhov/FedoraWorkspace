# Proxmox Deployment

Proxmox is only a deployment target for this system image.

The generic image is:

```text
ghcr.io/<owner>/fedora-workspace:latest
```

The base image intentionally does not include `cloud-init` or `qemu-guest-agent`. If you want Proxmox-native VM provisioning and guest status integration, build a Proxmox-specific variant that adds those packages.

## Basic Import

Use the `build-disk` workflow to produce a `qcow2` artifact, then upload `disk.qcow2` to the Proxmox host:

```bash
qm create 9000 \
  --name fedora-workspace \
  --memory 4096 \
  --cores 2 \
  --net0 virtio,bridge=vmbr0 \
  --ostype l26 \
  --bios ovmf \
  --machine q35 \
  --scsihw virtio-scsi-single

qm importdisk 9000 disk.qcow2 local-lvm
qm set 9000 --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=1
qm set 9000 --boot order=scsi0
qm set 9000 --serial0 socket --vga serial0
qm template 9000
```

This basic import does not configure users or SSH keys. Do that through your chosen provisioning path, or create a Proxmox-specific image variant with `cloud-init`.

## Optional Proxmox Variant

If you later want a Proxmox-specific variant, add a separate `Containerfile.proxmox`:

```Dockerfile
FROM ghcr.io/<owner>/fedora-workspace:latest

RUN dnf5 install -y cloud-init qemu-guest-agent && dnf5 clean all

RUN systemctl enable \
    cloud-init-local.service \
    cloud-init.service \
    cloud-config.service \
    cloud-final.service \
    qemu-guest-agent.service
```

Then publish it separately, for example:

```text
ghcr.io/<owner>/fedora-workspace-proxmox:latest
```
