# btrfs RAID1 cheatsheet (carl-pi `/srv/data`)

Two NVMe drives (`nvme0n1`, `nvme1n1`), one btrfs filesystem, label `data`.
RAID1 = every block exists on **both** drives → one drive may die, nothing is lost.
RAID1 is **not a backup**: deleting a file or a broken program deletes it on both drives. Snapshots (section 4) help against that, an external backup against losing the Pi.

Host aliases on carl-pi: `raid` = `btrfs filesystem usage`, `raidstat` = `btrfs device stats`, `data` = `cd /srv/data`.
Almost everything needs `sudo`.

## 1. Health check (do this now and then)

| Command | Does |
|---|---|
| `raidstat` | error counters per drive — **all should be 0** |
| `sudo btrfs scrub status /srv/data` | result of the last scrub (monthly cron, 1st at 03:00) |
| `sudo btrfs filesystem show /srv/data` | both drives listed? a missing one shows as `*** Some devices missing` |
| `sudo journalctl -k -g btrfs` | kernel messages about btrfs: errors, mounts, degraded |
| `findmnt /srv/data` | is it mounted, with which options |

What the counters mean:
- `write_io_errs` / `read_io_errs` / `flush_io_errs` → the drive or its connection has trouble
- `corruption_errs` → checksum didn't match (btrfs repaired it from the other copy if it could)
- `generation_errs` → drive missed writes (e.g. was missing for a while)

Reset counters after you fixed the cause, so new errors stand out: `sudo btrfs device stats -z /srv/data`

## 2. Space

| Command | Does |
|---|---|
| `raid` | full overview: size, used, free, profiles per drive |
| `sudo btrfs filesystem df /srv/data` | short: Data / Metadata / System and their profile (all should say `RAID1`) |
| `du1` / `df` | normal tools — `df` shows usable space, `du` doesn't know about compression |

With RAID1 "used" on each drive ≈ your data. Usable space ≈ the size of **one** drive (~465 GiB).
Compression (`compress=zstd:1` in fstab) means files often take less than their size.

## 3. Scrub — read everything, verify checksums, repair from the good copy

| Command | Does |
|---|---|
| `sudo btrfs scrub start /srv/data` | start in background |
| `sudo btrfs scrub start -B /srv/data` | start and wait (`-B` = foreground, what the cron job does) |
| `sudo btrfs scrub status /srv/data` | progress / result |
| `sudo btrfs scrub cancel /srv/data` | stop |

Run one after anything unusual: power loss, a drive that was missing, after a replace.

## 4. Subvolumes & snapshots

Subvolumes here: `docker`, `appdata`, `backups`, `files`, `.snapshots` (all under `/srv/data`).
A snapshot is an instant, space-sharing copy of a subvolume — it only grows as the original changes.

| Command | Does |
|---|---|
| `sudo btrfs subvolume list /srv/data` | all subvolumes + snapshots |
| `sudo btrfs subvolume snapshot -r /srv/data/files /srv/data/.snapshots/files-$(date +%F)` | read-only (`-r`) snapshot of `files`, named with today's date |
| `ls /srv/data/.snapshots/files-2026-11-28/` | a snapshot is just a folder — browse it |
| `cp /srv/data/.snapshots/files-2026-11-28/doc.pdf ~/files/` | restore one file = copy it back |
| `sudo btrfs subvolume delete /srv/data/.snapshots/files-2026-11-28` | delete a snapshot |

- Snapshot **before** risky changes: `sudo btrfs subvolume snapshot -r /srv/data/appdata /srv/data/.snapshots/appdata-before-update`
- Snapshots don't include nested subvolumes, and they live on the **same drives** → no protection if the Pi dies
- Don't snapshot `docker` — rebuild that with `docker compose pull && up -d` instead

## 5. If a drive dies

**Signs:** counters in `raidstat` going up, I/O errors in `dmesg`, `filesystem show` says devices missing, `/srv/data` not mounted after boot (fstab has `nofail`, so the Pi still boots).

```bash
# 1. which one? note the devid of the missing / failing drive
sudo btrfs filesystem show /srv/data
sudo btrfs device stats /srv/data
lsblk -o NAME,SIZE,MODEL,SERIAL            # match the drive to the physical one by serial

# 2. not mounted any more? mount with the one good drive
sudo mount -o degraded /dev/nvme0n1 /srv/data   # use the GOOD drive's name

# 3. shut down, swap in the new drive (same size or bigger), boot, mount degraded again, then:
sudo btrfs replace start <devid-of-dead> /dev/<new-drive> /srv/data
sudo btrfs replace status /srv/data        # wait until finished

# 4. anything written while degraded may be single-copy — convert back to RAID1, then verify
sudo btrfs balance start -dconvert=raid1,soft -mconvert=raid1,soft /srv/data
sudo btrfs filesystem df /srv/data         # everything RAID1 again?
sudo btrfs scrub start -B /srv/data
```

- Failing but still there? `replace` works with the old drive still connected — copy first, then remove it
- Don't stay degraded for long: until the replace is done you have **no** redundancy
- Don't run `btrfs check --repair` on a guess — it can make things worse. Ask first

## 6. Drive health (optional tools)

| Command | Does |
|---|---|
| `sudo smartctl -a /dev/nvme0n1` | SMART data: `Percentage Used`, `Media and Data Integrity Errors`, temperature (package `smartmontools`) |
| `sudo nvme smart-log /dev/nvme0n1` | same, NVMe tool (package `nvme-cli`) |
| `temp` | Pi CPU temperature |
