# TP2 : Appréhender l'environnement Linux

I.[Service SSH](#i-service-ssh)

- 1.[Analyse du service](#1-analyse-du-service)
- 2.[Modification du service](#2-modification-du-service)

II.[Service HTTP](#ii-service-http)

- 1.[Mise en place](#1-mise-en-place)
- 2.[Analyser la conf de NGINX](#2-analyser-la-conf-de-nginx)
- 3.[Déployer un nouveau site web](#3-déployer-un-nouveau-site-web)

III.[Your own services](#iii-your-own-services)

- 2.[Analyse des ervices existants](#2-analyse-des-services-existants)
- 3.[Création de services](#3-création-de-service)

## I. Service SSH
Le service SSH est déjà installé sur la machine, et il est aussi déjà démarré par défaut, c'est Rocky qui fait ça nativement.

### 1. Analyse du service

__🌞 S'assurer que le service sshd est démarré__

avec une commande systemctl status

```
[melanie@TP2 ~]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor pres>
     Active: active (running) since Fri 2022-12-09 13:37:16 CET; 55s ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 723 (sshd)
      Tasks: 1 (limit: 11072)
     Memory: 5.6M
        CPU: 48ms
     CGroup: /system.slice/sshd.service
             └─723 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

Dec 09 13:37:16 localhost systemd[1]: Starting OpenSSH server daemon...
Dec 09 13:37:16 localhost sshd[723]: Server listening on 0.0.0.0 port 22.
Dec 09 13:37:16 localhost sshd[723]: Server listening on :: port 22.
Dec 09 13:37:16 localhost systemd[1]: Started OpenSSH server daemon.
Dec 09 13:37:53 localhost.localdomain sshd[1245]: Accepted password for melanie>
Dec 09 13:37:53 localhost.localdomain sshd[1245]: pam_unix(sshd:session): sessi>
```

__🌞 Analyser les processus liés au service SSH__

afficher les processus liés au service sshd avec une commande ps

Filtrer la sortie de la commande en ajoutant |    grep <TEXTE_RECHERCHE> après une commande

- J'ai utilisé la commande ps -ef et j'ai ajouté | grep sshd pour cibler la recherche uniquement sur les processus en cours d'excution lié au sshd

ps -ef :      
-e = Affiche les processus en cours d’exécution de tous les utilisateurs

-f = Affiche la liste complète du format (affiche des informations supplémentaires sur les processus d’exécution)

```
[melanie@TP2 ~]$ ps -ef | grep sshd
root         723       1  0 13:37 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root        1245     723  0 13:37 ?        00:00:00 sshd: melanie [priv]
melanie     1249    1245  0 13:37 ?        00:00:00 sshd: melanie@pts/0
melanie     1276    1250  0 13:42 pts/0    00:00:00 grep --color=auto sshd
````

__🌞 Déterminer le port sur lequel écoute le service SSH__

avec une commande ss, isolez les lignes intéressantes avec un | grep <TEXTE>

```
[melanie@TP2 ~]$ sudo ss -alnpt | grep ssh
LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=730,fd=3))
LISTEN 0      128             [::]:22           [::]:*    users:(("sshd",pid=730,fd=4))
```
En écoute sur le port 22


__🌞 Consulter les logs du service SSH__

les logs du service sont consultables avec une commande journalctl,
un fichier de log qui répertorie toutes les tentatives de connexion SSH existe

il est dans le dossier /var/log/secure

journalctl -u | sshd

```
[melanie@TP2 ~]$ journalctl -xe -u sshd | tail -n 10
Dec 09 15:38:11 localhost systemd[1]: Started OpenSSH server daemon.
░░ Subject: A start job for unit sshd.service has finished successfully
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░
░░ A start job for unit sshd.service has finished successfully.
░░
░░ The job identifier is 218.
Dec 09 15:39:17 localhost.localdomain sshd[1253]: Accepted password for melanie from 192.168.56.1 port 50933 ssh2
Dec 09 17:39:17 localhost.localdomain sshd[1253]: pam_unix(sshd:session): session opened for user melanie(uid=1000) by (uid=0)
```
```
[melanie@TP2 ~]$ sudo cat /var/log/secure | grep sshd | tail -n 10
[sudo] password for melanie:
Dec 11 16:43:25 localhost sshd[1511]: Received disconnect from 192.168.56.1 port 57640:11: disconnected by user
Dec 11 16:43:25 localhost sshd[1511]: Disconnected from user melanie 192.168.56.1 port 57640
Dec 11 16:43:25 localhost sshd[1507]: pam_unix(sshd:session): session closed for user melanie
Dec 11 16:43:38 localhost sshd[1723]: Accepted password for melanie from 192.168.56.1 port 49970 ssh2
Dec 11 16:43:38 localhost sshd[1723]: pam_unix(sshd:session): session opened for user melanie(uid=1000) by (uid=0)
Dec 11 17:26:11 localhost sshd[1319]: pam_unix(sshd:session): session closed for user melanie
Dec 11 17:57:46 localhost sshd[737]: Server listening on 0.0.0.0 port 22.
Dec 11 17:57:46 localhost sshd[737]: Server listening on :: port 22.
Dec 11 17:59:34 localhost sshd[1253]: Accepted password for melanie from 192.168.56.1 port 50933 ssh2
Dec 11 17:59:34 localhost sshd[1253]: pam_unix(sshd:session): session opened for user melanie(uid=1000) by (uid=0)
```

### 2. Modification du service

__🌞 Identifier le fichier de configuration du serveur SSH__

```
[melanie@TP2 ~]$ ls /etc/ssh | grep sshd
sshd_config
sshd_config.d
```

le fichier de conf est sshd_config.d


__🌞 Modifier le fichier de conf__

exécutez un echo $RANDOM pour demander à votre shell de vous fournir un nombre aléatoire

```
[melanie@TP2 ~]$ echo $RANDOM
16832
```
VIM:
sudo vim -- i -> faire une modif; :w --> enregistrer; :q --> quitter (voir Mémo)

changez le port d'écoute du serveur SSH pour qu'il écoute sur ce numéro de port
```
[melanie@TP2 ~]$ sudo cat /etc/ssh/sshd_config | grep Port
Port 16832
#GatewayPorts no
```

- gérer le firewall

fermer l'ancien port

```
[melanie@TP2 ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports:
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
```
[melanie@TP2 ~]$ sudo firewall-cmd --remove-service ssh
success
```
```
[melanie@TP2 ~]$ sudo firewall-cmd --remove-service ssh --permanent
success
```
```
[melanie@TP2 ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client
  ports:
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

ouvrir le nouveau port

```
[melanie@TP2 ~]$ sudo firewall-cmd --add-port=16832/tcp --permanent
success
```

```
[melanie@TP2 ~]$ sudo firewall-cmd --reload
success
```

```
[melanie@TP2 ~]$ sudo firewall-cmd --list-all | grep port
  ports: 16832/tcp
  forward-ports:
  source-ports:
```
vérifier avec un firewall-cmd --list-all que le port est bien ouvert
```
[melanie@TP2 ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client
  ports: 16832/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

__🌞 Redémarrer le service__

```
[melanie@TP2 ~]$ sudo systemctl restart sshd
```


__🌞 Effectuer une connexion SSH sur le nouveau port__

```
$ ssh -p 16832 melanie@192.168.56.102
melanie@192.168.56.102's password:
Last login: Fri Dec  9 17:05:59 2022 from 192.168.56.1
```

## II. Service HTTP

### 1. Mise en place

__🌞 Installer le serveur NGINX__

installation:
```
[melanie@TP2 ~]$ sudo dnf install nginx
Last metadata expiration check: 2:19:27 ago on Fri 09 Dec 2022 03:20:08 PM CET.
Dependencies resolved.
================================================================================
 Package                Arch        Version                Repository      Size
================================================================================
Installing:
 nginx                  x86_64      1:1.20.1-13.el9        appstream       38 k
Installing dependencies:
 nginx-core             x86_64      1:1.20.1-13.el9        appstream      567 k
 nginx-filesystem       noarch      1:1.20.1-13.el9        appstream       11 k
 rocky-logos-httpd      noarch      90.13-1.el9            appstream       24 k

Transaction Summary
================================================================================
Install  4 Packages

Total download size: 640 k
Installed size: 1.8 M
Is this ok [y/N]: y
Downloading Packages:
(1/4): nginx-1.20.1-13.el9.x86_64.rpm           291 kB/s |  38 kB     00:00
(2/4): nginx-filesystem-1.20.1-13.el9.noarch.rp  75 kB/s |  11 kB     00:00
(3/4): rocky-logos-httpd-90.13-1.el9.noarch.rpm 162 kB/s |  24 kB     00:00
(4/4): nginx-core-1.20.1-13.el9.x86_64.rpm      4.3 MB/s | 567 kB     00:00
--------------------------------------------------------------------------------
Total                                           1.1 MB/s | 640 kB     00:00
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1
  Running scriptlet: nginx-filesystem-1:1.20.1-13.el9.noarch                1/4
  Installing       : nginx-filesystem-1:1.20.1-13.el9.noarch                1/4
  Installing       : nginx-core-1:1.20.1-13.el9.x86_64                      2/4
  Installing       : rocky-logos-httpd-90.13-1.el9.noarch                   3/4
  Installing       : nginx-1:1.20.1-13.el9.x86_64                           4/4
  Running scriptlet: nginx-1:1.20.1-13.el9.x86_64                           4/4
  Verifying        : rocky-logos-httpd-90.13-1.el9.noarch                   1/4
  Verifying        : nginx-filesystem-1:1.20.1-13.el9.noarch                2/4
  Verifying        : nginx-1:1.20.1-13.el9.x86_64                           3/4
  Verifying        : nginx-core-1:1.20.1-13.el9.x86_64                      4/4

Installed:
  nginx-1:1.20.1-13.el9.x86_64             nginx-core-1:1.20.1-13.el9.x86_64
  nginx-filesystem-1:1.20.1-13.el9.noarch  rocky-logos-httpd-90.13-1.el9.noarch

Complete!
```

__🌞 Démarrer le service NGINX__

```
[melanie@TP2 ~]$ sudo systemctl enable nginx
sudo systemctl start nginx
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
```
```
[melanie@TP2 ~]$ sudo systemctl start nginx
[melanie@TP2 ~]$
```

```
[melanie@TP2 ~]$ sudo firewall-cmd --permanent --add-service=http
success
```

```
[melanie@TP2 ~]$ sudo firewall-cmd --permanent --zone=public --add-service=https
success
```

```
[melanie@TP2 ~]$ sudo firewall-cmd --reload
success
```

```
[melanie@TP2 ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor pre>
     Active: active (running) since Fri 2022-12-09 17:39:54 CET; 21min ago
   Main PID: 2355 (nginx)
      Tasks: 3 (limit: 11072)
     Memory: 2.8M
        CPU: 13ms
     CGroup: /system.slice/nginx.service
             ├─2355 "nginx: master process /usr/sbin/nginx"
             ├─2356 "nginx: worker process"
             └─2357 "nginx: worker process"

Dec 09 17:39:54 TP2 systemd[1]: Starting The nginx HTTP and reverse proxy serve>
Dec 09 17:39:54 TP2 nginx[2353]: nginx: the configuration file /etc/nginx/nginx>
Dec 09 17:39:54 TP2 nginx[2353]: nginx: configuration file /etc/nginx/nginx.con>
Dec 09 17:39:54 TP2 systemd[1]: Started The nginx HTTP and reverse proxy server.

```

__🌞 Déterminer sur quel port tourne NGINX__

vous devez filtrer la sortie de la commande utilisée pour n'afficher que les lignes demandées

```
[melanie@TP2 ~]$ sudo ss -alnpt | grep nginx
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=2357,fd=6),("nginx",pid=2356,fd=6),("nginx",pid=2355,fd=6))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=2357,fd=7),("nginx",pid=2356,fd=7),("nginx",pid=2355,fd=7))
```

NGINX écoute sur le port 80 

ouvrez le port concerné dans le firewall

```
[melanie@TP2 ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[melanie@TP2 ~]$ sudo firewall-cmd --reload
success
```

```
[melanie@TP2 ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client http https
  ports: 22/tcp 80/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

__🌞 Déterminer les processus liés à l'exécution de NGINX__

```
[melanie@TP2 ~]$ ps -ef | grep nginx
root        2355       1  0 17:39 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       2356    2355  0 17:39 ?        00:00:00 nginx: worker process
nginx       2357    2355  0 17:39 ?        00:00:00 nginx: worker process
melanie     2526    2157  0 18:09 pts/1    00:00:00 grep --color=auto nginx
```

__🌞 Euh wait__

ouvrez votre navigateur (sur votre PC) et visitez http://<IP_VM>:<PORT>

dans le compte-rendu, je veux le curl (pas un screen de navigateur)

```
[melanie@TP2 ~]$ curl 192.168.56.102:80 | head -7
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0  7441k      0 --:--:-- --:--:-- --:--:-- 7441k
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
```
### 2. Analyser la conf de NGINX
<br>

__🌞 Déterminer le path du fichier de configuration de NGINX__

```
[melanie@TP2 ~]$ ls -al /etc/nginx/nginx.conf
-rw-r--r--. 1 root root 2334 Oct 31 16:37 /etc/nginx/nginx.conf
```

__🌞 Trouver dans le fichier de conf__

ce que vous cherchez, c'est un bloc server { } dans le fichier de conf
vous ferez un cat <FICHIER> | grep <TEXTE> -A X 

```
[melanie@TP2 ~]$ cat /etc/nginx/nginx.conf | grep -n 'server {' -A 10
38:    server {
39-        listen       80;
40-        listen       [::]:80;
41-        server_name  _;
42-        root         /usr/share/nginx/html;
43-
44-        # Load configuration files for the default server block.
45-        include /etc/nginx/default.d/*.conf;
46-
47-        error_page 404 /404.html;
48-        location = /404.html {
--
58:#    server {
59-#        listen       443 ssl http2;
60-#        listen       [::]:443 ssl http2;
61-#        server_name  _;
62-#        root         /usr/share/nginx/html;
63-#
64-#        ssl_certificate "/etc/pki/nginx/server.crt";
65-#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
66-#        ssl_session_cache shared:SSL:1m;
67-#        ssl_session_timeout  10m;
68-#        ssl_ciphers PROFILE=SYSTEM;
```


- une ligne qui parle d'inclure d'autres fichiers de conf

encore un cat <FICHIER> | grep <TEXTE>

```
[melanie@TP2 ~]$ cat /etc/nginx/nginx.conf | grep include
include /usr/share/nginx/modules/*.conf;
    include             /etc/nginx/mime.types;
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/default.d/*.conf;
#        include /etc/nginx/default.d/*.conf;
[melanie@TP2 ~]$
```

### 3. Déployer un nouveau site web

__🌞 Créer un site web__

créer un sous-dossier dans /var/www/
```
[melanie@TP2 ~]$ sudo mkdir /var/www
[sudo] password for melanie:
```

par convention, on stocke les sites web dans /var/www/

votre dossier doit porter le nom tp2_linux

```
[melanie@TP2 ~]$ sudo mkdir /var/www/tp2_linux
```

dans ce dossier /var/www/tp2_linux, créez un fichier index.html
```
[melanie@TP2 ~]$ cd /var/www/tp2_linux/
[melanie@TP2 tp2_linux]$ touch index.html
touch: cannot touch 'index.html': Permission denied
[melanie@TP2 tp2_linux]$ sudo !!
sudo touch index.html
[sudo] password for melanie:
```

il doit contenir ```<h1>MEOW mon premier serveur web</h1>```
```
[melanie@TP2 tp2_linux]$ sudo nano index.html
[melanie@TP2 tp2_linux]$ ls
index.html
[melanie@TP2 tp2_linux]$ cat index.html
<h1>MEOW mon premier serveur web</h1>
```


__🌞 Adapter la conf NGINX__

dans le fichier de conf principal

vous supprimerez le bloc server {} repéré plus tôt pour que NGINX ne serve plus le site par défaut
```
[melanie@TP2 ~]$ sudo nano /etc/nginx/nginx.conf
[sudo] password for melanie:
[melanie@TP2 ~]$ sudo cat /etc/nginx/nginx.conf | grep server -A 10
# Settings for a TLS enabled server.
#
#    server {
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
#        server_name  _;
#        root         /usr/share/nginx/html;
#
#        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers PROFILE=SYSTEM;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        error_page 404 /404.html;
#            location = /40x.html {
#        }
#
#        error_page 500 502 503 504 /50x.html;
#            location = /50x.html {
#        }
#    }

```


redémarrez NGINX pour que les changements prennent effet
```
[melanie@TP2 ~]$ sudo systemctl restart nginx
```

créez un nouveau fichier de conf
il doit être nommé correctement (web.conf)
il doit être placé dans le bon dossier

```
[melanie@TP2 ~]$ echo $RANDOM
6717
```


```
[melanie@TP2 ~]$ cd /etc/nginx/conf.d/
[melanie@TP2 conf.d]$ sudo touch web.conf
[sudo] password for melanie:
[melanie@TP2 conf.d]$ sudo nano web.conf
[melanie@TP2 conf.d]$ cat web.conf
server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
  listen <PORT>;

  root /var/www/tp2_linux;
}
[melanie@TP2 conf.d]$ sudo nano web.conf
[melanie@TP2 conf.d]$ cat web.conf
server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
  listen 6717;

  root /var/www/tp2_linux;
}
```

On rétablit aussi le firewall

```
[melanie@TP2 conf.d]$ sudo firewall-cmd --add-port=6717/tcp --permanent
success
```
```
[melanie@TP2 conf.d]$ sudo firewall-cmd --reload
success
```
```
[melanie@TP2 conf.d]$ sudo firewall-cmd --list-all | grep ports
  ports: 22/tcp 80/tcp 6717/tcp
  forward-ports:
  source-ports:
```



redémarrez NGINX pour que les changements prennent effet
```
[melanie@TP2 conf.d]$ sudo systemctl restart nginx
[melanie@TP2 conf.d]$
```

__🌞 Visitez votre super site web__

toujours avec une commande curl depuis votre PC (ou un navigateur)
```
[melanie@TP2 conf.d]$ curl 192.168.56.102:6717
<h1>MEOW mon premier serveur web</h1>
```

## III. Your own services

### 1. Au cas où vous auriez oublié

### 2. Analyse des services existants

__🌞 Afficher le fichier de service SSH__

vous pouvez obtenir son chemin avec un systemctl status <SERVICE>

C'est la line "└─723 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups""
```
[melanie@TP2 ~]$ sudo systemctl status sshd
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2022-12-11 14:36:03 CET; 1h 40min ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 723 (sshd)
      Tasks: 1 (limit: 11072)
     Memory: 8.0M
        CPU: 207ms
     CGroup: /system.slice/sshd.service
             └─723 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

Dec 11 14:36:03 localhost sshd[723]: Server listening on :: port 22.
Dec 11 14:36:03 localhost systemd[1]: Started OpenSSH server daemon.
Dec 11 14:36:45 localhost.localdomain sshd[1249]: Accepted password for melanie from 192.168.56.1 port 53870 ssh2
Dec 11 14:36:45 localhost.localdomain sshd[1249]: pam_unix(sshd:session): session opened for user melanie(uid=1000) by (uid=0)
Dec 11 14:38:20 TP2 sshd[1280]: Accepted password for melanie from 192.168.56.1 port 53872 ssh2
Dec 11 14:38:20 TP2 sshd[1280]: pam_unix(sshd:session): session opened for user melanie(uid=1000) by (uid=0)
Dec 11 14:44:05 TP2 sshd[1319]: Accepted password for melanie from 192.168.56.1 port 53887 ssh2
Dec 11 14:44:05 TP2 sshd[1319]: pam_unix(sshd:session): session opened for user melanie(uid=1000) by (uid=0)
Dec 11 16:00:44 TP2 sshd[1507]: Accepted password for melanie from 192.168.56.1 port 57640 ssh2
Dec 11 16:00:44 TP2 sshd[1507]: pam_unix(sshd:session): session opened for user melanie(uid=1000) by (uid=0)
```

mettez en évidence la ligne qui commence par ExecStart=

encore un cat <FICHIER> | grep <TEXTE>

```
[melanie@TP2 ~]$ cat /usr/lib/systemd/system/sshd.service | grep ExecStart=
ExecStart=/usr/sbin/sshd -D $OPTIONS
```
taper systemctl start <SERVICE>
```
[melanie@TP2 ~]$ systemctl start sshd
Failed to start sshd.service: Access denied
See system logs and 'systemctl status sshd.service' for details.
[melanie@TP2 ~]$ sudo !!
sudo systemctl start sshd
[sudo] password for melanie:
```


__🌞 Afficher le fichier de service NGINX__

mettez en évidence la ligne qui commence par ExecStart=
```
[melanie@TP2 ~]$ cat /usr/lib/systemd/system/nginx.service | grep ExecStart=
ExecStart=/usr/sbin/nginx
```
### 3. Création de service

__🌞 Créez le fichier /etc/systemd/system/tp2_nc.service__

```
[melanie@TP2 ~]$ echo $RANDOM
20430
```

```
[melanie@TP2 ~]$ cd /etc/system
systemd/            system-release      system-release-cpe
[melanie@TP2 ~]$ cd /etc/system
systemd/            system-release      system-release-cpe
[melanie@TP2 ~]$ cd /etc/systemd/system/
[melanie@TP2 system]$ sudo touch tp2_nc.service
```

```
[melanie@TP2 system]$ sudo nano tp2_nc.service
[melanie@TP2 system]$ cat tp2_nc.service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 20430
```
```
[melanie@TP2 system]$ sudo firewall-cmd --add-port=20430/tcp --permanent
success
```
```
[melanie@TP2 system]$ sudo firewall-cmd --reload
success
```
```
[melanie@TP2 system]$ sudo firewall-cmd --list-all | grep ports
  ports: 22/tcp 80/tcp 6717/tcp 8888/tcp 20430/tcp
  forward-ports:
  source-ports:
```
__🌞 Indiquer au système qu'on a modifié les fichiers de service__

```
[melanie@TP2 system]$ sudo systemctl daemon-reload
```
__🌞 Démarrer notre service de ouf__

avec une commande systemctl start

```
[melanie@TP2 ~]$ sudo systemctl start tp2_nc
```

__🌞 Vérifier que ça fonctionne__

vérifier que le service tourne avec un systemctl status <SERVICE>
```

[melanie@TP2 ~]$ sudo systemctl status tp2_nc
● tp2_nc.service - Super netcat tout fou
     Loaded: loaded (/etc/systemd/system/tp2_nc.service; static)
     Active: active (running) since Sun 2022-12-11 17:25:32 CET; 12s ago
   Main PID: 1868 (nc)
      Tasks: 1 (limit: 11072)
     Memory: 784.0K
        CPU: 5ms
     CGroup: /system.slice/tp2_nc.service
             └─1868 /usr/bin/nc -l 20430

Dec 11 17:25:32 TP2 systemd[1]: Started Super netcat tout fou.
```
vérifier que nc écoute bien derrière un port avec un ss
vous filtrerez avec un | grep la sortie de la commande pour n'afficher que les lignes intéressantes

```
[melanie@TP2 ~]$ sudo ss -alnpt | grep nc
LISTEN 0      10           0.0.0.0:20430      0.0.0.0:*    users:(("nc",pid=1868,fd=4))
LISTEN 0      10              [::]:20430         [::]:*    users:(("nc",pid=1868,fd=3))
```

__🌞 Les logs de votre service__

sudo journalctl -xe -u tp2_nc pour visualiser les logs de votre service

sudo journalctl -xe -u tp2_nc -f  pour visualiser en temps réel les logs de votre service


une commande journalctl filtrée avec grep qui affiche la ligne qui indique le démarrage du service
```
[melanie@TP2 ~]$ sudo journalctl -xe -u tp2_nc | grep start
░░ Subject: A start job for unit tp2_nc.service has finished successfully
░░ A start job for unit tp2_nc.service has finished successfully.
░░ Subject: A start job for unit tp2_nc.service has finished successfully
░░ A start job for unit tp2_nc.service has finished successfully.
░░ Subject: A start job for unit tp2_nc.service has finished successfully
░░ A start job for unit tp2_nc.service has finished successfully.
░░ Subject: A start job for unit tp2_nc.service has finished successfully
░░ A start job for unit tp2_nc.service has finished successfully.
░░ Subject: A start job for unit tp2_nc.service has finished successfully
░░ A start job for unit tp2_nc.service has finished successfully.
░░ Subject: A start job for unit tp2_nc.service has finished successfully
░░ A start job for unit tp2_nc.service has finished successfully.
░░ Subject: A start job for unit tp2_nc.service has finished successfully
░░ A start job for unit tp2_nc.service has finished successfully.
░░ Subject: A start job for unit tp2_nc.service has finished successfully
░░ A start job for unit tp2_nc.service has finished successfully.
░░ Subject: A start job for unit tp2_nc.service has finished successfully
░░ A start job for unit tp2_nc.service has finished successfully.

```

une commande journalctl filtrée avec grep qui affiche un message reçu qui a été envoyé par le client
```
[melanie@TP2 ~]$ sudo journalctl -xe -u tp2_nc | grep "ok"
Dec 11 17:33:25 TP2 nc[1868]: ok
```

une commande journalctl filtrée avec grep qui affiche la ligne qui indique l'arrêt du service
```
[melanie@TP2 ~]$ sudo journalctl -xe -u tp2_nc | grep exit
 Dec 11 17:39:23 TP2 systemd[1]: tp2_nc.service: Failed with result 'exit-code'.
░░ The unit tp2_nc.service has entered the 'failed' state with result 'exit-code
```


__🌞 Affiner la définition du service__

faire en sorte que le service redémarre automatiquement s'il se termine

comme ça, quand un client se co, puis se tire, le service se relancera tout seul
ajoutez Restart=always dans la section [Service] de votre service
n'oubliez pas d'indiquer au système que vous avez modifié les fichiers de service 

```
[melanie@TP2 ~]$ sudo nano /etc/systemd/system/tp2_nc.service
[melanie@TP2 ~]$ sudo cat /etc/systemd/system/tp2_nc.service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 20430
Restart=always
```
```
[melanie@TP2 ~]$ sudo systemctl daemon-reload
```
