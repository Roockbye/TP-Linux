## Partie 2 : Mise en place et maîtrise du serveur de base de données

🖥️ VM db.tp5.linux

__🌞 Install de MariaDB sur db.tp5.linux__

```
[melanie@db ~]$ sudo !!
sudo dnf install mariadb-server
Complete!
```

```
[melanie@db ~]$ sudo systemctl enable mariadb
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.
```

````
[melanie@db ~]$ sudo systemctl start mariadb
```

```
[melanie@db ~]$ sudo mysql_secure_installation
Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

```
[melanie@db ~]$ sudo systemctl enable mariadb.service
[melanie@db ~]$ sudo systemctl start mariadb.service
[melanie@db ~]$ sudo systemctl status mariadb.service
● mariadb.service - MariaDB 10.5 database server
     Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled; vendor preset:>
     Active: active (running) since Tue 2023-01-17 12:12:20 CET; 16min ago
       Docs: man:mariadbd(8)
             https://mariadb.com/kb/en/library/systemd/
   Main PID: 4185 (mariadbd)
     Status: "Taking your SQL requests now..."
      Tasks: 8 (limit: 11116)
     Memory: 82.3M
        CPU: 1.862s
     CGroup: /system.slice/mariadb.service
             └─4185 /usr/libexec/mariadbd --basedir=/usr

Jan 17 12:12:20 db.linux.tp5 mariadb-prepare-db-dir[4141]: you need to be the system >
Jan 17 12:12:20 db.linux.tp5 mariadb-prepare-db-dir[4141]: After connecting you can s>
Jan 17 12:12:20 db.linux.tp5 mariadb-prepare-db-dir[4141]: able to connect as any of >
Jan 17 12:12:20 db.linux.tp5 mariadb-prepare-db-dir[4141]: See the MariaDB Knowledgeb>
Jan 17 12:12:20 db.linux.tp5 mariadb-prepare-db-dir[4141]: Please report any problems>
Jan 17 12:12:20 db.linux.tp5 mariadb-prepare-db-dir[4141]: The latest information abo>
Jan 17 12:12:20 db.linux.tp5 mariadb-prepare-db-dir[4141]: Consider joining MariaDB's>
Jan 17 12:12:20 db.linux.tp5 mariadb-prepare-db-dir[4141]: https://mariadb.org/get-in>
Jan 17 12:12:20 db.linux.tp5 mariadbd[4185]: 2023-01-17 12:12:20 0 [Note] /usr/libexe>
Jan 17 12:12:20 db.linux.tp5 systemd[1]: Started MariaDB 10.5 database server.
```
```
[melanie@db ~]$ sudo systemctl is-enabled mariadb.service
enabled
````

__🌞 Port utilisé par MariaDB__

```
[melanie@db ~]$ ss -alpnt | grep maria
State    Recv-Q   Send-Q       Local Address:Port       Peer Address:Port   Process
LISTEN   0        128                0.0.0.0:22              0.0.0.0:*
LISTEN   0        80                       *:3306                  *:*
```
Il ecoute sur le port 3306

```
[melanie@db ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
success
[melanie@db ~]$ sudo firewall-cmd --reload
success
```
```
[melanie@db ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 3306/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
[melanie@db ~]$
```
__🌞 Processus liés à MariaDB__

```
[melanie@db ~]$ ps -ef | grep maria
mysql       4185       1  0 12:12 ?        00:00:01 /usr/libexec/mariadbd --basedir=/usr
melanie     4416    1211  0 12:34 pts/0    00:00:00 grep --color=auto maria
```