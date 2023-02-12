# Module 2 : Sauvegarde du système de fichiers

## I. Script de backup
### 1. Ecriture du script
### 2. Clean it

__🌞 Ecrire le script bash__


[script backup](script.sh)

```
[melanie@web srv]$ sudo ./tp6_backup.sh 
Filename : nextcloud_222113214307.tar.gz saved in /srv/backup
```      

### 3. Service et timer

__🌞 Créez un service système qui lance le script__

[Backup](backup.sh)
```
[melanie@web ~]$ cat /etc/systemd/system/backup.service
[Unit]
Description=Backup nextcloud

[Service]
Type=oneshot
ExecStart=/srv/tp6_backup.sh
User=backup
```
```
[melanie@web ~]$ sudo systemctl start backup
```

__🌞 Créez un timer système qui lance le service à intervalles__

```
[melanie@web ~]$ sudo nano /etc/systemd/system/backup.timer
```

```
[melanie@web ~]$ sudo cat /etc/systemd/system/backup.timer
[Unit]
Description=Service Backup

[Timer]
OnCalendar=*-*-* 1:00:00

[Install]
WantedBy=timers.target
```

__🌞 Activez l'utilisation du timer__

```
[melanie@web ~]$ sudo systemctl daemon-reload
```
```
[melanie@web ~]$ sudo systemctl start backup.timer
```
```
[melanie@web ~]$ sudo systemctl enable backup.timer
Created symlink /etc/systemd/system/timers.target.wants/backup.timer → /etc/systemd/system/backup.timer.
```
```
[melanie@web ~]$ sudo systemctl status backup.timer
● backup.timer - Run service Backup
     Loaded: loaded (/etc/systemd/system/backup.timer; enabled; vendor pres>     Active: active (waiting) since Sun 2023-02-12 22:23:17 CET; 1min 18s a>      Until: Sun 2023-02-12 22:23:17 CET; 1min 18s ago
    Trigger: Mond 2023-02-13 00:10:00 CET; 2h left
   Triggers: ● backup.service

Feb 12 22:23:17 web.tp.linux5 systemd[1]: Started Run service Backup.
```



## II. NFS
### 1. Serveur NFS

🖥️ VM storage.tp6.linux

__🌞 Préparer un dossier à partager sur le réseau (sur la machine storage.tp6.linux)__

```
[melanie@storage ~]$ sudo /srv/nfs_shares/
```
```
[melanie@storage ~]$ sudo mkdir /srv/nfs_shares/web.tp6.linux/
```
```
[melanie@storage ~]$ sudo chown nobody /srv/nfs_shares/web.tp6.linux/
```

__🌞 Installer le serveur NFS (sur la machine storage.tp6.linux)__

```
[melanie@storage ~]$ sudo dnf install -y nfs-utils

Complete!
```
```
[melanie@storage ~]$ cat /etc/exports
/srv/nfs_shares/web.tp6.linux/ 10.105.1.11(rw,sync,no_subtree_check)
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
```

### 2. Client NFS

__🌞 Installer un client NFS sur web.tp6.linux__

```
[melanie@web ~]$ sudo mount 10.105.1.11:/srv/nfs_shares/web.tp6.linux/ /srv/backup/
```

```
[melanie@web ~]$ sudo cat /etc/fstab | grep 10.105.1.11
10.105.1.11:/srv/nfs_shares/web.tp6.linux/ /srv/backup nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
```




__🌞 Tester la restauration des données sinon ça sert à rien :)__