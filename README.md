# Merlin Clash

YOU-KNOW-WHAT: Clash app for koolshare firmware on hnd device.

## Setup Entware (Optware alternative) on asuswrt-merlin

### 1. Prepare: Configure Router

- Enable SSH
- Enable JFFS custom scripts and configs (Format JFFS partition at next boot)

### 2. Prepare: Plug a USB Disk

The USB disk must be formatted to a native Linux filesystem. (ext2, ext3 or ext4)

```txt
ywhjames@RT-AX88U-4558:/tmp/home/root# df
Filesystem           1K-blocks      Used Available Use% Mounted on
ubi:rootfs_ubifs         71104     71104         0 100% /
devtmpfs                451680         0    451680   0% /dev
tmpfs                   451792       856    450936   0% /var
tmpfs                   451792     12556    439236   3% /tmp/mnt
mtd:bootfs                5248      4244      1004  81% /bootfs
mtd:data                  8192       608      7584   7% /data
tmpfs                   451792     12556    439236   3% /tmp/mnt
tmpfs                   451792     12556    439236   3% /tmp
/dev/mtdblock9           64512     19276     45236  30% /jffs
/dev/sda              29904860     69612  28293104   0% /tmp/mnt/sda

ywhjames@RT-AX88U-4558:/jffs# mount
ubi:rootfs_ubifs on / type ubifs (ro,relatime)
devtmpfs on /dev type devtmpfs (rw,relatime,size=451680k,nr_inodes=112920,mode=755)
proc on /proc type proc (rw,relatime)
tmpfs on /var type tmpfs (rw,relatime)
tmpfs on /tmp/mnt type tmpfs (rw,relatime,size=16k,mode=755)
sysfs on /sys type sysfs (rw,relatime)
debugfs on /sys/kernel/debug type debugfs (rw,relatime)
mtd:bootfs on /bootfs type jffs2 (ro,relatime)
devpts on /dev/pts type devpts (rw,relatime,mode=600)
mtd:data on /data type jffs2 (rw,relatime)
tmpfs on /tmp/mnt type tmpfs (rw,relatime,size=16k,mode=755)
tmpfs on /tmp type tmpfs (rw,relatime)
/dev/mtdblock9 on /jffs type jffs2 (rw,noatime)
/dev/sda on /tmp/mnt/sda type ext4 (rw,nodev,relatime,data=ordered)
```

### 3. Install Entware

```bash
amtm

# or, for version older than 384.15 (or 384.13_4 for the RT-AC87U and RT-AC3200)
entware-setup.sh
```

## Credit

- [merlinclash_hnd](https://github.com/flyhigherpi/merlinclash_hnd)
