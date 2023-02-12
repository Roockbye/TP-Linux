# Module 1 : Reverse Proxy

## I. Setup
🖥️ VM proxy.tp6.linux

__🌞 On utilisera NGINX comme reverse proxy__
```
[melanie@proxy ~]$sudo dnf update

Complete!
```
```
[melanie@proxy ~]$sudo dnf install nginx

Complete!
```
```
[melanie@proxy ~]$ sudo systemctl enable nginx
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
```
```
[melanie@proxy ~]$ sudo systemctl start nginx
```
```
[melanie@proxy ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor pre>
     Active: active (running) since Tue 2023-01-31 14:08:19 CET; 11s ago
    Process: 11112 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, sta>
    Process: 11113 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCE>
    Process: 11114 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 11115 (nginx)
      Tasks: 3 (limit: 11116)
     Memory: 2.8M
        CPU: 54ms
     CGroup: /system.slice/nginx.service
             ├─11115 "nginx: master process /usr/sbin/nginx"
             ├─11116 "nginx: worker process"
             └─11117 "nginx: worker process"

Jan 31 14:08:19 proxy.tp6.linux systemd[1]: Starting The nginx HTTP and reverse>
Jan 31 14:08:19 proxy.tp6.linux nginx[11113]: nginx: the configuration file /et>
Jan 31 14:08:19 proxy.tp6.linux nginx[11113]: nginx: configuration file /etc/ng>
Jan 31 14:08:19 proxy.tp6.linux systemd[1]: Started The nginx HTTP and reverse >
```

```
[melanie@proxy ~]$ sudo ss -alpnt | grep nginx
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=11117,fd=6),("nginx",pid=11116,fd=6),("nginx",pid=11115,fd=6))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=11117,fd=7),("nginx",pid=11116,fd=7),("nginx",pid=11115,fd=7))
```
Il ecoute sur le port 80

```
[melanie@proxy ~]$ sudo firewall-cmd --permanent --add-service=http
success
```
```
[melanie@proxy ~]$ sudo firewall-cmd --permanent --list-all
public
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: cockpit dhcpv6-client http ssh
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
[melanie@proxy ~]$ sudo firewall-cmd --reload
success
```

```
[melanie@proxy ~]$ ps -ef | grep nginx
root       11115       1  0 14:24 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx      11116   11115  0 14:24 ?        00:00:00 nginx: worker process
nginx      11117   11115  0 14:24 ?        00:00:00 nginx: worker process
melanie    53759    1208  0 14:43 pts/0    00:00:00 grep --color=auto nginx
```

```
[melanie@proxy ~]$ curl 10.105.1.13 | head -n 10
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0  3720k      0 --:--:-- --:--:-- --:--:-- 7441k
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

__🌞 Configurer NGINX__

```
[melanie@proxy nginx]$ sudo vim TP6.conf
[melanie@proxy nginx]$ cat TP6.conf
server {
        # On indique le nom que client va saisir pour accéder au service
        # Pas d'erreur ici, c'est bien le nom de web, et pas de proxy qu'on veut ici !
    server_name www.nextcloud.tp6;

        # Port d'écoute de NGINX
    listen 80;

    location / {
        # On définit des headers HTTP pour que le proxying se passe bien
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying
        proxy_pass http://<IP_DE_NEXTCLOUD>:80;
    }

        # Deux sections location recommandés par la doc NextCloud
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
}
```
```
[melanie@web ~]$ sudo cat /var/www/tp5_nextcloud/config/config.php
[sudo] password for melanie:
<?php
$CONFIG = array (
  'instanceid' => 'oc8fkpj6z888',
  'passwordsalt' => 'elHPtIOuzSNqRtnB+Z717gahLVZ2sb',
  'secret' => 'xClQSCxGjeEYyMOiId/YLKhcRUv+FOJcsCDMB9oWPg8mVqld',
  'trusted_domains' =>
  array (
    0 => 'web.tp5.linux',
    1 => '10.105.1.13',
  ),
  'datadirectory' => '/var/www/tp5_nextcloud/data',
  'dbtype' => 'mysql',
  'version' => '25.0.0.15',
  'overwrite.cli.url' => 'http://web.tp5.linux',
  'dbname' => 'nextcloud',
  'dbhost' => '10.105.1.12',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'mysql.utf8mb4' => true,
  'dbuser' => 'nextcloud',
  'dbpassword' => 'pewpewpew',
  'installed' => true,
);
```

➜ Modifier votre fichier hosts de VOTRE PC
```
10.105.1.13	proxy.tp6.linux www.nextcloud.tp6
```

__🌞 Faites en sorte de__

```
[melanie@web ~]$ sudo firewall-cmd --set-default-zone drop
[sudo] password for melanie:
success
```
```
[melanie@web ~]$ sudo firewall-cmd --permanent --zone=drop --change-source=10.105.1.13
success
````
```
[melanie@web ~]$ sudo firewall-cmd --reload
success
```
```
[melanie@web ~]$ sudo firewall-cmd --list-all
drop (active)
  target: DROP
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources: 10.105.1.13
  services:
  ports:
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

__🌞 Une fois que c'est en place__

```
C:\Users\Melanie>ping 10.105.1.13

Envoi d’une requête 'Ping'  10.105.1.13 avec 32 octets de données :
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64

Statistiques Ping pour 10.105.1.13:
    Paquets : envoyés = 4, reçus = 4, perdus = 0 (perte 0%),
Durée approximative des boucles en millisecondes :
    Minimum = 0ms, Maximum = 0ms, Moyenne = 0ms
```

```
C:\Users\Melanie>ping 10.105.1.11

Envoi d’une requête 'Ping'  10.105.1.11 avec 32 octets de données :
Délai d’attente de la demande dépassé.
Délai d’attente de la demande dépassé.

Statistiques Ping pour 10.105.1.11:
    Paquets : envoyés = 2, reçus = 0, perdus = 2 (perte 100%),
```

## II. HTTPS

__🌞 Faire en sorte que NGINX force la connexion en HTTPS plutôt qu'HTTP__

```
[melanie@proxy ~]$ openssl genrsa -out private.key 2048
```
```
[melanie@proxy ~]$ openssl req -new -x509 -key private.key -out certificate.crt
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:
State or Province Name (full name) []:
Locality Name (eg, city) [Default City]:
Organization Name (eg, company) [Default Company Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:
Email Address []:
```
(j'ai juste fait entrer à chaque fois)

```
[melanie@proxy ~]$ cd /etc/n
nanorc             nftables/          nsswitch.conf
networks           nginx/             nsswitch.conf.bak
[melanie@proxy ~]$ cd /etc/nginx/
conf.d/                 koi-utf                 scgi_params
default.d/              koi-win                 scgi_params.default
fastcgi.conf            mime.types              TP6.conf
fastcgi.conf.default    mime.types.default      uwsgi_params
fastcgi_params          nginx.conf              uwsgi_params.default
fastcgi_params.default  nginx.conf.default      win-utf
[melanie@proxy ~]$ sudo nano /etc/nginx/TP6.conf
```
```
[melanie@proxy ~]$ sudo cat /etc/nginx/TP6.conf
server {
        # On indique le nom que client va saisir pour accéder au service
        # Pas d'erreur ici, c'est bien le nom de web, et pas de proxy qu'on veut ici !
    server_name web.tp5.linux;

        # Port d'écoute de NGINX
    listen 80;

    location / {
        # On définit des headers HTTP pour que le proxying se passe bien
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying
        proxy_pass http://10.105.1.11:80;
    }

        # Deux sections location recommandés par la doc NextCloud
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
        listen 443 ssl;
    ssl_certificate /home/nathan/certificate.crt;
    ssl_certificate_key /home/nathan/private.key;
}
```

```
[melanie@proxy ~]$ sudo firewall-cmd --add-port=443/tcp --permanent
[sudo] password for melanie:
success
```
```
[melanie@proxy ~]$ sudo firewall-cmd --reload
success
```
```
[melanie@proxy ~]$ sudo systemctl restart nginx
```
```
[melanie@proxy ~]$ curl 10.105.1.13 | grep https
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0  7441k      0 --:--:-- --:--:-- --:--:-- 7441k
          <a href="https://rockylinux.org/"><strong>Rocky Linux
        <a href="https://httpd.apache.org/">Apache Webserver</strong></a>:
        <a href="https://nginx.org">Nginx</strong></a>:
          <a href="https://rockylinux.org/" id="rocky-poweredby"><img src="icons/poweredby.png" alt="[ Powered by Rocky Linux ]" /></a> <!-- Rocky -->
      <a href="https://apache.org">Apache&trade;</a> is a registered trademark of <a href="https://apache.org">the Apache Software Foundation</a> in the United States and/or other countries.<br />
      <a href="https://nginx.org">NGINX&trade;</a> is a registered trademark of <a href="https://">F5 Networks, Inc.</a>.
```