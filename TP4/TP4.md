# TP4 : Real services

## Partie 1 : Partitionnement du serveur de stockage

🖥️ VM storage.tp4.linux


__🌞 Partitionner le disque à l'aide de LVM__

Ajouter le(s) disque(s) en tant que PV (Physical Volume) dans LVM
```
[melanie@storage ~]$ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda           8:0    0   20G  0 disk
├─sda1        8:1    0    1G  0 part /boot
└─sda2        8:2    0   19G  0 part
  ├─rl-root 253:0    0   17G  0 lvm  /
  └─rl-swap 253:1    0    2G  0 lvm  [SWAP]
sdb           8:16   0    2G  0 disk
sr0          11:0    1 1024M  0 rom
```

```
[melanie@storage ~]$ sudo pvcreate /dev/sdb
[sudo] password for melanie:
  Physical volume "/dev/sdb" successfully created.
```

```
[melanie@storage ~]$ sudo pvs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBb0e0fcf6-4f49906e_ PVID jpiRPsUOFlEXSl0eDYLJTmViLRIO2c4h last seen on /dev/sda2 not found.
  PV         VG Fmt  Attr PSize  PFree
  /dev/sdb      lvm2 ---  <2.00g <2.00g
[melanie@storage ~]$ sudo pvdisplay
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBb0e0fcf6-4f49906e_ PVID jpiRPsUOFlEXSl0eDYLJTmViLRIO2c4h last seen on /dev/sda2 not found.
  "/dev/sdb" is a new physical volume of "<2.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb
  VG Name
  PV Size               <2.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               QE7JJG-eldk-AIT6-W4lU-c9sa-eMTI-7gtI9A
```
Créer un VG (Volume Group):
```
[melanie@storage ~]$ sudo vgcreate storage /dev/sdb
  Volume group "storage" successfully created
[melanie@storage ~]$ sudo vgs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBb0e0fcf6-4f49906e_ PVID jpiRPsUOFlEXSl0eDYLJTmViLRIO2c4h last seen on /dev/sda2 not found.
  VG      #PV #LV #SN Attr   VSize VFree
  storage   1   0   0 wz--n- 1.99g 1.99g
[melanie@storage ~]$ sudo vgdisplay
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBb0e0fcf6-4f49906e_ PVID jpiRPsUOFlEXSl0eDYLJTmViLRIO2c4h last seen on /dev/sda2 not found.
  --- Volume group ---
  VG Name               storage
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               1.99 GiB
  PE Size               4.00 MiB
  Total PE              510
  Alloc PE / Size       0 / 0
  Free  PE / Size       510 / 1.99 GiB
  VG UUID               rfruNb-KStl-qrw0-5v4k-uice-p1y6-UpTXeA
```

```
[melanie@storage ~]$ sudo lvcreate -l 100%FREE storage -n new_storage
  Logical volume "new_storage" created.
[melanie@storage ~]$ sudo lvs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBb0e0fcf6-4f49906e_ PVID jpiRPsUOFlEXSl0eDYLJTmViLRIO2c4h last seen on /dev/sda2 not found.
  LV          VG      Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  new_storage storage -wi-a----- 1.99g
[melanie@storage ~]$ sudo lvdisplay
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBb0e0fcf6-4f49906e_ PVID jpiRPsUOFlEXSl0eDYLJTmViLRIO2c4h last seen on /dev/sda2 not found.
  --- Logical volume ---
  LV Path                /dev/storage/new_storage
  LV Name                new_storage
  VG Name                storage
  LV UUID                ZeTL0A-bGKf-mupI-T5O9-lwdn-e9WQ-vJB3R7
  LV Write Access        read/write
  LV Creation host, time storage.tp4.linux, 2023-01-10 16:39:50 +0100
  LV Status              available
  # open                 0
  LV Size                1.99 GiB
  Current LE             510
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2

[melanie@storage ~]$ lsblk
NAME                  MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                     8:0    0   20G  0 disk
├─sda1                  8:1    0    1G  0 part /boot
└─sda2                  8:2    0   19G  0 part
  ├─rl-root           253:0    0   17G  0 lvm  /
  └─rl-swap           253:1    0    2G  0 lvm  [SWAP]
sdb                     8:16   0    2G  0 disk
└─storage-new_storage 253:2    0    2G  0 lvm
sr0                    11:0    1 1024M  0 rom
```
__🌞 Formater la partition__

``` 
[melanie@storage ~]$ mkfs -t ext4 /dev/storage/new_storage
mke2fs 1.46.5 (30-Dec-2021)
mkfs.ext4: Permission denied while trying to determine filesystem size
[melanie@storage ~]$ sudo !!
sudo mkfs -t ext4 /dev/storage/new_storage
[sudo] password for melanie:
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 522240 4k blocks and 130560 inodes
Filesystem UUID: 57196fb2-f987-4add-ae70-e3120d7ca256
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```
```
[melanie@storage ~]$ sudo lvdisplay
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBb0e0fcf6-4f49906e_ PVID jpiRPsUOFlEXSl0eDYLJTmViLRIO2c4h last seen on /dev/sda2 not found.
  --- Logical volume ---
  LV Path                /dev/storage/new_storage
  LV Name                new_storage
  VG Name                storage
  LV UUID                ZeTL0A-bGKf-mupI-T5O9-lwdn-e9WQ-vJB3R7
  LV Write Access        read/write
  LV Creation host, time storage.tp4.linux, 2023-01-10 16:39:50 +0100
  LV Status              available
  # open                 0
  LV Size                1.99 GiB
  Current LE             510
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2
```

__🌞 Monter la partition__
```
[melanie@storage ~]$ sudo mkdir /mnt/storage
[melanie@storage ~]$ sudo mount /dev/storage/new_storage /mnt/storage/
[melanie@storage ~]$ sudo lvdisplay | grep Path
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBb0e0fcf6-4f49906e_ PVID jpiRPsUOFlEXSl0eDYLJTmViLRIO2c4h last seen on /dev/sda2 not found.
  LV Path                /dev/storage/new_storage
[melanie@storage ~]$ df -h | grep storage
/dev/mapper/storage-new_storage  2.0G   24K  1.9G   1% /mnt/storage
```

```
[melanie@storage ~]$ cat preuve
test preuve
```

```
[melanie@storage ~]$ cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Sun Nov  6 17:11:37 2022
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
/dev/mapper/rl-root     /                       xfs     defaults        0 0
UUID=fd8f7901-3075-4635-a9b5-fdd24d653662 /boot                   xfs     defaults        0 0
/dev/mapper/rl-swap     none                    swap    defaults        0 0
/dev/storage/new_storage /mnt/storage ext4 defaults 0 0
```
```
[melanie@storage ~]$ sudo umount /mnt/storage/
umount: /mnt/storage/: not mounted.
[melanie@storage ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount: /mnt/storage does not contain SELinux labels.
       You just mounted a file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
/mnt/storage             : successfully mounted
```
```
[melanie@storage ~]$ sudo reboot
Connection to 192.168.56.106 closed by remote host.
Connection to 192.168.56.106 closed.
```

## Partie 2 : Serveur de partage de fichiers

<br>

__🌞 Donnez les commandes réalisées sur le serveur NFS storage.tp4.linux__










 


