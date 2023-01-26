## Partie 3 : Configuration et mise en place de NextCloud

### 1. Base de données

__🌞 Préparation de la base pour NextCloud__
```
[melanie@db ~]$ sudo mysql -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 5
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
```

```
MariaDB [(none)]> CREATE USER 'nextcloud'@'10.105.1.11' IDENTIFIED BY 'pewpewpew';
Query OK, 0 rows affected (0.005 sec)

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.002 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.105.1.11';
Query OK, 0 rows affected (0.005 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.001 sec)
MariaDB [(none)]> \q
Bye
```

__🌞 Exploration de la base de données__

password:pewpewpew

```
[melanie@web ~]$ sudo mysql -u nextcloud -h 10.105.1.12 -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 10
Server version: 5.5.5-10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> SHOW DATABASES;
SHOW TABLES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.00 sec)

mysql> USE <DATABASE_NAME>;
ERROR 1044 (42000): Access denied for user 'nextcloud'@'10.105.1.11' to database '<DATABASE_NAME>'
mysql> SHOW TABLES;
ERROR 1046 (3D000): No database selected
mysql> USE <DATABASE_NAME>;
ERROR 1044 (42000): Access denied for user 'nextcloud'@'10.105.1.11' to database '<DATABASE_NAME>'
mysql> USE nextcloud;
Database changed
mysql> SHOW TABLES;
Empty set (0.00 sec)

mysql> \q
Bye
```
```
[melanie@db ~]$ sudo mysql -u root -p
[sudo] password for melanie:
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 11
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> SELECT User FROM mysql.user;
+-------------+
| User        |
+-------------+
| nextcloud   |
| mariadb.sys |
| mysql       |
| root        |
+-------------+
4 rows in set (0.003 sec)
```
### 2. Serveur Web et NextCloud

⚠️⚠️⚠️ N'OUBLIEZ PAS de réinitialiser votre conf Apache avant de continuer. En particulier, remettez le port et le user par défaut.

__🌞 Install de PHP__

```
[melanie@web conf]$ sudo dnf config-manager --set-enabled crb
[melanie@web conf]$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
Complete!
[melanie@web conf]$ dnf module list php
Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
[melanie@web conf]$ sudo dnf module enable php:remi-8.1 -y
Complete!
[melanie@web conf]$ sudo dnf install -y php81-php
Complete!
```

__🌞 Install de tous les modules PHP nécessaires pour NextCloud__

```
[melanie@web conf]$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
Complete!
```

__🌞 Récupérer NextCloud__
```
[melanie@web ~]$ sudo mkdir /var/www/tp5_nextcloud/
```
```
[melanie@web ~]$ sudo curl https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip --output /var/www/tp5_nextcloud/nextcloud.zip
```
```
[melanie@web ~]$ sudo dnf install unzip -y
```
```
[melanie@web ~]$ unzip /var/www/tp5_nextcloud/nextcloud.zip  
```
```  
[melanie@web tp5_nextcloud]$ sudo mv ~/nextcloud/* ../tp5_nextcloud/    
```

```
[melanie@web ~]$ ls  /var/www/tp5_nextcloud/ | grep index.html
index.html
```
```
[melanie@web ~]$ ls -al /var/www/tp5_nextcloud/
total 172344
drwxr-xr-x. 14 root    root         4096 Jan 26 13:03 .
drwxr-xr-x.  5 root    root           54 Jan 26 12:57 ..
drwxr-xr-x. 47 melanie melanie      4096 Oct  6 14:47 3rdparty
drwxr-xr-x. 50 melanie melanie      4096 Oct  6 14:44 apps
-rw-r--r--.  1 melanie melanie     19327 Oct  6 14:42 AUTHORS
drwxr-xr-x.  2 melanie melanie        67 Oct  6 14:47 config
-rw-r--r--.  1 melanie melanie      4095 Oct  6 14:42 console.php
-rw-r--r--.  1 melanie melanie     34520 Oct  6 14:42 COPYING
drwxr-xr-x. 23 melanie melanie      4096 Oct  6 14:47 core
-rw-r--r--.  1 melanie melanie      6317 Oct  6 14:42 cron.php
drwxr-xr-x.  2 melanie melanie      8192 Oct  6 14:42 dist
-rw-r--r--.  1 melanie melanie       156 Oct  6 14:42 index.html
-rw-r--r--.  1 melanie melanie      3456 Oct  6 14:42 index.php
drwxr-xr-x.  6 melanie melanie       125 Oct  6 14:42 lib
-rw-r--r--.  1 root    root    176341139 Jan 26 13:00 nextcloud.zip
-rw-r--r--.  1 melanie melanie       283 Oct  6 14:42 occ
drwxr-xr-x.  2 melanie melanie        23 Oct  6 14:42 ocm-provider
drwxr-xr-x.  2 melanie melanie        55 Oct  6 14:42 ocs
drwxr-xr-x.  2 melanie melanie        23 Oct  6 14:42 ocs-provider
-rw-r--r--.  1 melanie melanie      3139 Oct  6 14:42 public.php
-rw-r--r--.  1 melanie melanie      5426 Oct  6 14:42 remote.php
drwxr-xr-x.  4 melanie melanie       133 Oct  6 14:42 resources
-rw-r--r--.  1 melanie melanie        26 Oct  6 14:42 robots.txt
-rw-r--r--.  1 melanie melanie      2452 Oct  6 14:42 status.php
drwxr-xr-x.  3 melanie melanie        35 Oct  6 14:42 themes
drwxr-xr-x.  2 melanie melanie        43 Oct  6 14:44 updater
-rw-r--r--.  1 melanie melanie       387 Oct  6 14:47 version.php
```
```
[melanie@web ~]$ sudo chown -R apache:apache /var/www/tp5_nextcloud/
[melanie@web ~]$ ls -al /var/www/tp5_nextcloud/
total 172344
drwxr-xr-x. 14 apache apache      4096 Jan 26 13:03 .
drwxr-xr-x.  5 root   root          54 Jan 26 12:57 ..
drwxr-xr-x. 47 apache apache      4096 Oct  6 14:47 3rdparty
drwxr-xr-x. 50 apache apache      4096 Oct  6 14:44 apps
-rw-r--r--.  1 apache apache     19327 Oct  6 14:42 AUTHORS
drwxr-xr-x.  2 apache apache        67 Oct  6 14:47 config
-rw-r--r--.  1 apache apache      4095 Oct  6 14:42 console.php
-rw-r--r--.  1 apache apache     34520 Oct  6 14:42 COPYING
drwxr-xr-x. 23 apache apache      4096 Oct  6 14:47 core
-rw-r--r--.  1 apache apache      6317 Oct  6 14:42 cron.php
drwxr-xr-x.  2 apache apache      8192 Oct  6 14:42 dist
-rw-r--r--.  1 apache apache       156 Oct  6 14:42 index.html
-rw-r--r--.  1 apache apache      3456 Oct  6 14:42 index.php
drwxr-xr-x.  6 apache apache       125 Oct  6 14:42 lib
-rw-r--r--.  1 apache apache 176341139 Jan 26 13:00 nextcloud.zip
-rw-r--r--.  1 apache apache       283 Oct  6 14:42 occ
drwxr-xr-x.  2 apache apache        23 Oct  6 14:42 ocm-provider
drwxr-xr-x.  2 apache apache        55 Oct  6 14:42 ocs
drwxr-xr-x.  2 apache apache        23 Oct  6 14:42 ocs-provider
-rw-r--r--.  1 apache apache      3139 Oct  6 14:42 public.php
-rw-r--r--.  1 apache apache      5426 Oct  6 14:42 remote.php
drwxr-xr-x.  4 apache apache       133 Oct  6 14:42 resources
-rw-r--r--.  1 apache apache        26 Oct  6 14:42 robots.txt
-rw-r--r--.  1 apache apache      2452 Oct  6 14:42 status.php
drwxr-xr-x.  3 apache apache        35 Oct  6 14:42 themes
drwxr-xr-x.  2 apache apache        43 Oct  6 14:44 updater
-rw-r--r--.  1 apache apache       387 Oct  6 14:47 version.php
```

__🌞 Adapter la configuration d'Apache__

```
[melanie@web ~]$ sudo nano /etc/httpd/conf.d/tp5cloud.conf
[melanie@web ~]$ sudo systemctl restart httpd
[melanie@web ~]$ sudo cat /etc/httpd/conf.d/tp5cloud.conf
<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp5_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp5.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp5_nextcloud/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

### 3. Finaliser l'installation de NextCloud

__🌞 Exploration de la base de données__

```
[melanie@db ~]$ sudo mysql -u root -p
[sudo] password for melanie:
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 14
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.


MariaDB [(none)]> SELECT count(*) AS number FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'nextcloud';
+--------+
| number |
+--------+
|      95 |
+--------+
1 row in set (0.001 sec)
```
