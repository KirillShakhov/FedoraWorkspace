# Proxmox Deployment

Proxmox is only a deployment target for this system image.

The generic image is:

```text
ghcr.io/<owner>/fedora-workspace:latest
```

For Proxmox, use the `build-disk` workflow to produce a `qcow2` artifact, then import that disk into a VM or template.

## Import `qcow2`

Upload `disk.qcow2` to the Proxmox host, then:

```bash
qm create 9000 \
  --name fedora-bootc \
  --memory 4096 \
  --cores 2 \
  --net0 virtio,bridge=vmbr0 \
  --ostype l26 \
  --agent enabled=1 \
  --bios ovmf \
  --machine q35 \
  --scsihw virtio-scsi-single

qm importdisk 9000 disk.qcow2 local-lvm
qm set 9000 --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=1
qm set 9000 --boot order=scsi0
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --ide2 local-lvm:cloudinit
qm template 9000
```

Create a VM from the template:

```bash
qm clone 9000 101 --name fedora-bootc-101
qm set 101 --ciuser kirill
qm set 101 --sshkeys ~/.ssh/authorized_keys
qm set 101 --ipconfig0 ip=dhcp
qm start 101
```

The `--ciuser` and `--sshkeys` values are the normal Proxmox cloud-init path. They can differ from the baked fallback user in `disk_config/config.toml`.

## Notes

- `qemu-guest-agent` is installed and enabled in the base image so Proxmox can report guest IPs and clean shutdown status.
- The image also includes `cloud-init`, which Proxmox can drive through the attached cloud-init disk.
- For private GHCR images, the running VM needs registry credentials before `bootc upgrade` can pull updates.
