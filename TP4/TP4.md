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
```
[melanie@storage ~]$ sudo mkdir /storage/site_web_1 -p
[melanie@storage ~]$ sudo mkdir /storage/site_web_2 -p
[melanie@storage ~]$ ls -dl /storage/site_web_1
drwxr-xr-x. 2 root root 6 Jan 15 13:46 /storage/site_web_1
[melanie@storage ~]$ ls -dl /storage/site_web_2
drwxr-xr-x. 2 root root 6 Jan 15 13:47 /storage/site_web_2
```
```
[melanie@storage ~]$ sudo chown nobody:nobody /storage/site_web_1/
[melanie@storage ~]$ sudo chown nobody:nobody /storage/site_web_2/
```
```
[melanie@storage ~]$ sudo nano /etc/exports
[sudo] password for melanie:
[melanie@storage ~]$ cat /etc/exports
/storage/site_web_1/ 192.168.56.105(rw,sync,no_root_squash,no_subtree_check)
/storage/site_web_2/ 192.168.56.105(rw,sync,no_root_squash,no_subtree_check)
```


```
[melanie@storage ~]$ sudo systemctl enable nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
[melanie@storage ~]$ sudo systemctl start nfs-server
[melanie@storage ~]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendo>
     Active: active (exited) since Sun 2023-01-15 13:53:17 CET; 13s ago
    Process: 1415 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUC>
    Process: 1416 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
    Process: 1434 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; then>
   Main PID: 1434 (code=exited, status=0/SUCCESS)
        CPU: 56ms

Jan 15 13:53:16 storage.tp4.linux systemd[1]: Starting NFS server and services.>
Jan 15 13:53:17 storage.tp4.linux systemd[1]: Finished NFS server and services.
```
```
[melanie@storage ~]$ sudo firewall-cmd --permanent --add-service=nfs
success
[melanie@storage ~]$ sudo firewall-cmd --permanent --add-service=mountd
success
[melanie@storage ~]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[melanie@storage ~]$ sudo firewall-cmd --reload
success
[melanie@storage ~]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client mountd nfs rpc-bind ssh
```


__🌞 Donnez les commandes réalisées sur le client NFS web.tp4.linux__
```
[melanie@web ~]$ sudo mkdir -p /var/www/site_web_1
[melanie@web ~]$ sudo mkdir -p /var/www/site_web_2
```
```
[melanie@web ~]$ sudo mount 192.168.56.106:/storage/site_web_1 /var/www/site_web_1

[melanie@web ~]$ sudo mount 192.168.56.106:/storage/site_web_2 /var/www/site_web_2
```

```
[melanie@web ~]$ df -h
Filesystem                          Size  Used Avail Use% Mounted on
devtmpfs                            869M     0  869M   0% /dev
tmpfs                               888M     0  888M   0% /dev/shm
tmpfs                               355M  5.0M  350M   2% /run
/dev/mapper/rl-root                  17G  1.3G   16G   8% /
/dev/sda1                          1014M  272M  743M  27% /boot
tmpfs                               178M     0  178M   0% /run/user/1000
192.168.56.106:/storage/site_web_1   17G  1.3G   16G   8% /var/www/site_web_1
192.168.56.106:/storage/site_web_2   17G  1.3G   16G   8% /var/www/site_web_2
```

```
[melanie@web ~]$ sudo touch /var/www/site_web_1/site_web_1.test
[melanie@web ~]$ sudo touch /var/www/site_web_2/site_web_2.test
[melanie@web ~]$ ls -l /var/www/site_web_1/site_web_1.test
-rw-r--r--. 1 root root 0 Jan 16 14:35 /var/www/site_web_1/site_web_1.test
[melanie@web ~]$ ls -l /var/www/site_web_2/site_web_2.test
-rw-r--r--. 1 root root 0 Jan 16 14:36 /var/www/site_web_2/site_web_2.test
```
```
[melanie@web ~]$ cat /etc/fstab

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
192.168.56.106:/storage/site_web_1   /var/www/site_web_1     nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
192.168.56.106:/storage/site_web_2   /var/www/site_web_2     nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
```
 
## Partie 3 : Serveur web
### 1. Intro NGINX
### 2. Install
🖥️ VM web.tp4.linux

sudo dnf install nginx

sudo systemctl enable --now nginx

__🌞 Installez NGINX__

### 3. Analyse

```
[melanie@web ~]$ sudo systemctl start nginx
[sudo] password for melanie:
[melanie@web ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor pre>
     Active: active (running) since Mon 2023-01-16 14:56:36 CET; 5min ago
    Process: 1595 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, stat>
    Process: 1596 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCES>
    Process: 1597 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 1598 (nginx)
      Tasks: 3 (limit: 11116)
     Memory: 2.8M
        CPU: 43ms
     CGroup: /system.slice/nginx.service
             ├─1598 "nginx: master process /usr/sbin/nginx"
             ├─1599 "nginx: worker process"
             └─1600 "nginx: worker process"

Jan 16 14:56:36 web.tp4.linux systemd[1]: Starting The nginx HTTP and reverse p>
Jan 16 14:56:36 web.tp4.linux nginx[1596]: nginx: the configuration file /etc/n>
Jan 16 14:56:36 web.tp4.linux nginx[1596]: nginx: configuration file /etc/nginx>
Jan 16 14:56:36 web.tp4.linux systemd[1]: Started The nginx HTTP and reverse pr>
lines 1-19/19 (END)

```
__🌞 Analysez le service NGINX__

```
[melanie@web ~]$ ps -ef | grep nginx
root        1598       1  0 14:56 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       1599    1598  0 14:56 ?        00:00:00 nginx: worker process
nginx       1600    1598  0 14:56 ?        00:00:00 nginx: worker process
melanie     1633    1283  0 15:08 pts/0    00:00:00 grep --color=auto nginx
```
```
[melanie@web ~]$ sudo ss -alpnt | grep nginx
[sudo] password for melanie:
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=1600,fd=6),("nginx",pid=1599,fd=6),("nginx",pid=1598,fd=6))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=1600,fd=7),("nginx",pid=1599,fd=7),("nginx",pid=1598,fd=7))
```
```
[melanie@web nginx]$ cat nginx.conf | grep root
        root         /usr/share/nginx/html;
#        root         /usr/share/nginx/html;
```
```
[melanie@web /]$ cd usr/share/nginx/html/
[melanie@web html]$ ls -al
total 12
drwxr-xr-x. 3 root root  143 Jan 16 14:56 .
drwxr-xr-x. 4 root root   33 Jan 16 14:56 ..
-rw-r--r--. 1 root root 3332 Oct 31 16:35 404.html
-rw-r--r--. 1 root root 3404 Oct 31 16:35 50x.html
drwxr-xr-x. 2 root root   27 Jan 16 14:56 icons
lrwxrwxrwx. 1 root root   25 Oct 31 16:37 index.html -> ../../testpage/index.html
-rw-r--r--. 1 root root  368 Oct 31 16:35 nginx-logo.png
lrwxrwxrwx. 1 root root   14 Oct 31 16:37 poweredby.png -> nginx-logo.png
lrwxrwxrwx. 1 root root   37 Oct 31 16:37 system_noindex_logo.png -> ../../pixmaps/system-noindex-logo.png
```

## 4. Visite du service web

__🌞 Configurez le firewall pour autoriser le trafic vers le service NGINX__
```
[melanie@web html]$ sudo firewall-cmd --add-port=80/tcp --permanent
[sudo] password for melanie:
success
[melanie@web html]$ sudo firewall-cmd --reload
success
```
__🌞 Accéder au site web__
curl -s http://   head -n 10
```
[melanie@web html]$ curl -s http://192.168.56.105 | head -n 8
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/
```

__🌞 Vérifier les logs d'accès__

```
[melanie@web html]$ sudo cat /var/log/nginx/access.log | tail -n 3
192.168.56.1 - - [16/Jan/2023:15:27:39 +0100] "GET /icons/poweredby.png HTTP/1.1" 200 15443 "http://192.168.56.105/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0) Gecko/20100101 Firefox/108.0" "-"
192.168.56.1 - - [16/Jan/2023:15:27:39 +0100] "GET /poweredby.png HTTP/1.1" 200 368 "http://192.168.56.105/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0) Gecko/20100101 Firefox/108.0" "-"
192.168.56.1 - - [16/Jan/2023:15:27:39 +0100] "GET /favicon.ico HTTP/1.1" 404 3332 "http://192.168.56.105/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0) Gecko/20100101 Firefox/108.0" "-"
```
## 5. Modif de la conf du serveur web

__🌞 Changer le port d'écoute__

```
[melanie@web nginx]$ sudo nano /etc/nginx/nginx.conf
[melanie@web nginx]$ sudo cat nginx.conf | grep 8080
        listen       8080;
        listen       [::]:8080;
```
```
[melanie@web nginx]$ sudo systemctl restart nginx
```
```
[melanie@web nginx]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
     Active: active (running) since Mon 2023-01-16 15:53:30 CET; 3s ago
    Process: 1762 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 1763 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 1764 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 1766 (nginx)
      Tasks: 3 (limit: 11116)
     Memory: 2.8M
        CPU: 23ms
     CGroup: /system.slice/nginx.service
             ├─1766 "nginx: master process /usr/sbin/nginx"
             ├─1767 "nginx: worker process"
             └─1768 "nginx: worker process"

Jan 16 15:53:30 web.tp4.linux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jan 16 15:53:30 web.tp4.linux nginx[1763]: nginx: the configuration file /etc/nginx/nginx.conf s>
Jan 16 15:53:30 web.tp4.linux nginx[1763]: nginx: configuration file /etc/nginx/nginx.conf test >
Jan 16 15:53:30 web.tp4.linux systemd[1]: Started The nginx HTTP and reverse proxy server.
```
```
[melanie@web nginx]$ sudo ss -alpnt | grep nginx
LISTEN 0      511          0.0.0.0:8080      0.0.0.0:*    users:(("nginx",pid=1768,fd=6),("nginx",pid=1767,fd=6),("nginx",pid=1766,fd=6))
LISTEN 0      511             [::]:8080         [::]:*    users:(("nginx",pid=1768,fd=7),("nginx",pid=1767,fd=7),("nginx",pid=1766,fd=7))
```
```
[melanie@web nginx]$ sudo firewall-cmd --add-port=8080/tcp --permanent
success
```
```
[melanie@web nginx]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
```
```
[melanie@web nginx]$ sudo firewall-cmd --reload
success
```
```
[melanie@web nginx]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 8080/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
```
```
[melanie@web nginx]$ curl -s http://192.168.56.105:8080 | head -n 8
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/
```

__🌞 Changer l'utilisateur qui lance le service__

```
[melanie@web nginx]$ sudo useradd web -m -p qsd
[sudo] password for melanie:
```
```
[melanie@web nginx]$ sudo nano nginx.conf
```
```
[melanie@web nginx]$ sudo cat nginx.conf | grep user
user web;
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
[melanie@web nginx]$ sudo systemctl restart nginx
```
```
[melanie@web nginx]$ ps -ef | grep nginx
root        1865       1  0 16:30 ?        00:00:00 nginx: master process /usr/sbin/nginx
web         1866    1865  0 16:30 ?        00:00:00 nginx: worker process
web         1867    1865  0 16:30 ?        00:00:00 nginx: worker process
melanie     1874    1283  0 16:33 pts/0    00:00:00 grep --color=auto nginx
```
__🌞 Changer l'emplacement de la racine Web__

```
[melanie@web site_web_1]$ sudo nano index.html
[sudo] password for melanie:
[melanie@web site_web_1]$ cat index.html
#index.html
changemetn emplacement de la racine webbbbbb
```
```
[melanie@web nginx]$ sudo nano nginx.conf
```
```
[melanie@web nginx]$ cat nginx.conf | grep web
user web;
        root         /var/www/site_web_1/;
```
```
[melanie@web nginx]$ curl -s http://192.168.56.105:8080 | head -n 8
#index.html
changemetn emplacement de la racine webbbbbb
```
__6. Deux sites web sur un seul serveur__

__🌞 Repérez dans le fichier de conf__

```
[melanie@web nginx]$ cat nginx.conf | grep conf.d
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    include /etc/nginx/conf.d/*.conf;
```

__🌞 Créez le fichier de configuration pour le premier site__

```
[melanie@web conf.d]$ sudo nano site_web_1.conf
[sudo] password for melanie:
[melanie@web conf.d]$ ls
site_web_1.conf
[melanie@web conf.d]$ cat site_web_1.conf
#Ajout bloc server
 server {
        listen       8080;
        listen       [::]:8080;
        server_name  _;
        root         /var/www/site_web_1/;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```

__🌞 Créez le fichier de configuration pour le deuxième site__

```
[melanie@web conf.d]$ sudo nano site_web_2.conf
[melanie@web conf.d]$ cat site_web_2.conf
#Ajout bloc server 2
 server {
        listen       8888;
        listen       [::]:8888;
        server_name  _;
        root         /var/www/site_web_2/;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```

```
[melanie@web conf.d]$ sudo firewall-cmd --add-port=8888/tcp --permanent
success
[melanie@web conf.d]$ sudo firewall-cmd --reload
success
[melanie@web conf.d]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 8080/tcp 8888/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
__🌞 Prouvez que les deux sites sont disponibles__

site_web_1
```
[melanie@web conf.d]$ curl http://192.168.56.105:8080 | head -n 8
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    57  100    57    0     0   4750      0 --:--:-- --:--:-- --:--:--  5181
#index.html
changemetn emplacement de la racine webbbbbb

```
site_web_2
```
[melanie@web conf.d]$ curl http://192.168.56.105:8888 | head -n 8
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   153  100   153    0     0  11769      0 --:--:-- --:--:-- --:--:-- 11769
#index2.html
stay tough
```