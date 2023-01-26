# TP5 : Self-hosted cloud

## Partie 1 : Mise en place et maîtrise du serveur Web

### 1. Installation

__🌞 Installer le serveur Apache__

```
[melanie@web ~]$ sudo dnf install httpd
```
[melanie@web conf]$ sudo vim httpd.conf
opt: :g/^ *#.*/d

__🌞 Démarrer le service Apache__

```
[melanie@web conf]$ sudo systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
[melanie@web conf]$ sudo systemctl start httpd
[melanie@web conf]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disable>
     Active: active (running) since Tue 2023-01-17 10:27:54 CET; 5s ago
       Docs: man:httpd.service(8)
   Main PID: 11245 (httpd)
     Status: "Started, listening on: port 80"
      Tasks: 213 (limit: 11116)
     Memory: 39.1M
        CPU: 278ms
     CGroup: /system.slice/httpd.service
             ├─11245 /usr/sbin/httpd -DFOREGROUND
             ├─11246 /usr/sbin/httpd -DFOREGROUND
             ├─11247 /usr/sbin/httpd -DFOREGROUND
             ├─11248 /usr/sbin/httpd -DFOREGROUND
             └─11249 /usr/sbin/httpd -DFOREGROUND

Jan 17 10:27:54 web.linux.tp5 systemd[1]: Starting The Apache HTTP Server...
Jan 17 10:27:54 web.linux.tp5 systemd[1]: Started The Apache HTTP Server.
Jan 17 10:27:54 web.linux.tp5 httpd[11245]: Server configured, listening on: port 80
lines 1-19/19 (END)
```
Apache démarre automatiquement au démarrage de la machine
```
[melanie@web conf]$ systemctl enable httpd.service
Failed to enable unit: Access denied
[melanie@web conf]$ sudo !!
sudo systemctl enable httpd.service
[melanie@web conf]$ sudo systemctl is-enabled httpd.service
enabled
```
```
[melanie@web conf]$ sudo ss -alpnt | grep httpd
LISTEN 0      511                *:80              *:*    users:(("httpd",pid=11249,fd=4),("httpd",pid=11248,fd=4),("httpd",pid=11247,fd=4),("httpd",pid=11245,fd=4))
```
Apache ecoute sur le port 80
```
[melanie@web conf]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[melanie@web conf]$ sudo firewall-cmd --reload
success
[melanie@web conf]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 80/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

__🌞 TEST__

```
[melanie@web conf]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disable>
     Active: active (running) since Tue 2023-01-17 10:27:54 CET; 14min ago
       Docs: man:httpd.service(8)
   Main PID: 11245 (httpd)
     Status: "Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:>
      Tasks: 213 (limit: 11116)
     Memory: 39.1M
        CPU: 4.349s
     CGroup: /system.slice/httpd.service
             ├─11245 /usr/sbin/httpd -DFOREGROUND
             ├─11246 /usr/sbin/httpd -DFOREGROUND
             ├─11247 /usr/sbin/httpd -DFOREGROUND
             ├─11248 /usr/sbin/httpd -DFOREGROUND
             └─11249 /usr/sbin/httpd -DFOREGROUND

Jan 17 10:27:54 web.linux.tp5 systemd[1]: Starting The Apache HTTP Server...
Jan 17 10:27:54 web.linux.tp5 systemd[1]: Started The Apache HTTP Server.
Jan 17 10:27:54 web.linux.tp5 httpd[11245]: Server configured, listening on: port 80
```
```
[melanie@web conf]$ sudo systemctl is-enabled httpd.service
enabled
```
```
[melanie@web ~]$ sudo systemctl is-active httpd
[sudo] password for melanie:
active
```
```
[melanie@web conf]$ curl web.linux.tp5 | head -n 10
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0   118k      0 --:--:-- --:--:-- --:--:--  118k
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
```
depuis mon PC:
```
 ~ (master)
$ curl -s 10.105.1.11 | head -n 3
<!doctype html>
<html>
  <head>
  <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>

```
### 2. Avancer vers la maîtrise du service

__🌞 Le service Apache...__
```
[melanie@web system]$ cat httpd.service
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#       [Service]
#       Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue

[Install]
WantedBy=multi-user.target
```
```
[melanie@web system]$ cat httpd.service | head -n 22 | tail -n 3
[Service]
Type=notify
Environment=LANG=C
```

__🌞 Déterminer sous quel utilisateur tourne le processus Apache__
```
[melanie@web conf]$ cat httpd.conf | grep User
User apache
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
```
```
[melanie@web testpage]$ ps -ef | grep apache
apache     11246   11245  0 10:27 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache     11247   11245  0 10:27 ?        00:00:03 /usr/sbin/httpd -DFOREGROUND
apache     11248   11245  0 10:27 ?        00:00:03 /usr/sbin/httpd -DFOREGROUND
apache     11249   11245  0 10:27 ?        00:00:03 /usr/sbin/httpd -DFOREGROUND
melanie    11597    1207  0 11:07 pts/0    00:00:00 grep --color=auto apache
```

```
[melanie@web testpage]$ ls -al
total 12
drwxr-xr-x.  2 root root   24 Jan 17 10:16 .
drwxr-xr-x. 83 root root 4096 Jan 17 10:16 ..
-rw-r--r--.  1 root root 7620 Jul 27 20:05 index.html
```
__🌞 Changer l'utilisateur utilisé par Apache__

```
[melanie@web testpage]$ sudo useradd webap -m -p qsd
[sudo] password for melanie:
```

```
[melanie@web etc]$ cat passwd | grep Apache
apache:x:48:48:Apache:/usr/share/httpd:/sbin/nologin
```
```
[melanie@web conf]$ vim httpd.conf
[melanie@web conf]$ sudo !!
sudo vim httpd.conf
[melanie@web conf]$ cat httpd.conf | grep User
User webap
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
```
```
[melanie@web conf]$ sudo systemctl restart httpd
```

```
[melanie@web conf]$ ps -ef | grep webap
webap      11723   11721  0 11:26 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
webap      11724   11721  0 11:26 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
webap      11725   11721  0 11:26 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
webap      11726   11721  0 11:26 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
melanie    11944    1207  0 11:26 pts/0    00:00:00 grep --color=auto webap
```
__🌞 Faites en sorte que Apache tourne sur un autre port__

```
[melanie@web conf]$ sudo vim httpd.conf
[melanie@web conf]$ cat httpd.conf | grep Listen
Listen 8081
```
```
[melanie@web conf]$ sudo firewall-cmd --add-port=8081/tcp --permanent
success
[melanie@web conf]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[melanie@web conf]$ sudo firewall-cmd --reload
success
[melanie@web conf]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 22/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
```
[melanie@web conf]$ sudo systemctl start httpd.service
[melanie@web conf]$ sudo systemctl reload httpd.service
[melanie@web conf]$ sudo systemctl status httpd.service
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2023-01-17 11:55:24 CET; 10s ago
       Docs: man:httpd.service(8)
    Process: 12391 ExecReload=/usr/sbin/httpd $OPTIONS -k graceful (code=exited, status=0/SUCCESS)
   Main PID: 12171 (httpd)
     Status: "Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec"
      Tasks: 213 (limit: 11116)
     Memory: 28.9M
        CPU: 354ms
     CGroup: /system.slice/httpd.service
             ├─12171 /usr/sbin/httpd -DFOREGROUND
             ├─12392 /usr/sbin/httpd -DFOREGROUND
             ├─12393 /usr/sbin/httpd -DFOREGROUND
             ├─12394 /usr/sbin/httpd -DFOREGROUND
             └─12395 /usr/sbin/httpd -DFOREGROUND

Jan 17 11:55:24 web.linux.tp5 systemd[1]: Starting The Apache HTTP Server...
Jan 17 11:55:24 web.linux.tp5 httpd[12171]: Server configured, listening on: port 8081
Jan 17 11:55:24 web.linux.tp5 systemd[1]: Started The Apache HTTP Server.
Jan 17 11:55:26 web.linux.tp5 systemd[1]: Reloading The Apache HTTP Server...
Jan 17 11:55:27 web.linux.tp5 systemd[1]: Reloaded The Apache HTTP Server.
Jan 17 11:55:27 web.linux.tp5 httpd[12171]: Server configured, listening on: port 8081
```
```
[melanie@web conf]$ ss -alpnt | grep 8081
LISTEN 0      511                *:8081            *:*
```
```
[melanie@web conf]$ curl http://10.105.1.11:8081 | head -n 8
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
<!doctype html>    0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/
100  7620  100  7620    0     0  2480k      0 --:--:-- --:--:-- --:--:-- 2480k
```

📁 Fichier [/etc/httpd/conf/httpd.conf](./httpd.conf)