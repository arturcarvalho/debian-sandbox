# Daily VM Snapshots on Proxmox VE (with rotation)

A small systemd timer that takes a daily snapshot of a VM and keeps only the most recent *N*, pruning older ones automatically.

> **Snapshots are not backups.** A snapshot lives on the same storage as the VM, so it's a fast rollback point — use it *alongside* your PBS backups, not instead of them. Snapshots are instant and cheap on ZFS; on other storage, keep the retention count low.

## Prerequisites

- Root shell on the **Proxmox VE host** (not the guest).
- The VM's disk(s) on snapshot-capable storage (ZFS, LVM-thin, qcow2, Ceph/RBD).
- The VM ID you want to snapshot (e.g. `105`). List guests with `qm list`.

## 1. Create the snapshot script

Edit `VMID` and `KEEP` at the top to taste, then paste the whole block into the PVE shell:

```bash
cat > /usr/local/bin/vm-autosnap.sh << 'EOF'
#!/usr/bin/env bash
set -uo pipefail

VMID=105                 # VM to snapshot
KEEP=7                   # number of daily snapshots to retain
PREFIX="autodaily"
NAME="${PREFIX}_$(date +%Y%m%d_%H%M%S)"

# disk-only snapshot (no RAM state -> fast)
if qm snapshot "$VMID" "$NAME" --description "automated daily"; then
    logger -t vm-autosnap "created $NAME on VM $VMID"
else
    logger -t vm-autosnap "ERROR creating snapshot on VM $VMID"; exit 1
fi

# keep newest $KEEP auto-snapshots, prune the rest
mapfile -t snaps < <(qm listsnapshot "$VMID" | grep -oE "${PREFIX}_[0-9]{8}_[0-9]{6}" | sort -u)
count=${#snaps[@]}
if (( count > KEEP )); then
    for old in "${snaps[@]:0:count-KEEP}"; do
        qm delsnapshot "$VMID" "$old" \
          && logger -t vm-autosnap "pruned $old" \
          || logger -t vm-autosnap "WARN could not delete $old"
    done
fi
EOF
chmod +x /usr/local/bin/vm-autosnap.sh
```

Pruning only ever matches the `autodaily_` prefix, so any snapshots you take by hand are left untouched.

## 2. Create the systemd service

```bash
cat > /etc/systemd/system/vm-autosnap.service << 'EOF'
[Unit]
Description=Daily VM snapshot with rotation

[Service]
Type=oneshot
ExecStart=/usr/local/bin/vm-autosnap.sh
EOF
```

## 3. Create the systemd timer

```bash
cat > /etc/systemd/system/vm-autosnap.timer << 'EOF'
[Unit]
Description=Daily VM snapshot

[Timer]
OnCalendar=*-*-* 03:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF
```

`Persistent=true` runs a missed snapshot at next boot if the host was off at the scheduled time.

## 4. Enable and test

```bash
systemctl daemon-reload
systemctl enable --now vm-autosnap.timer
systemctl start vm-autosnap.service     # run once now, don't wait for 03:00
qm listsnapshot 105                     # confirm the snapshot appears
```

Check the schedule and logs:

```bash
systemctl list-timers vm-autosnap.timer
journalctl -t vm-autosnap -e
```

## Adjusting it

- **Different VM or retention:** edit `VMID` / `KEEP` in `/usr/local/bin/vm-autosnap.sh`.
- **Different time:** edit `OnCalendar` in the timer (e.g. `*-*-* 02:30:00`), then `systemctl daemon-reload && systemctl restart vm-autosnap.timer`.

## Rolling back

List snapshots, then roll back (the VM should be stopped first):

```bash
qm listsnapshot 105
qm stop 105
qm rollback 105 autodaily_20260623_030000
qm start 105
```

## Removing it

```bash
systemctl disable --now vm-autosnap.timer
rm /etc/systemd/system/vm-autosnap.timer /etc/systemd/system/vm-autosnap.service
rm /usr/local/bin/vm-autosnap.sh
systemctl daemon-reload
```

Existing snapshots are left in place; delete any individually with `qm delsnapshot 105 <name>`.
