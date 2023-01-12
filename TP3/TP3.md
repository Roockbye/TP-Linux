# TP 3 : We do a little scripting

## 0. Un premier script

➜ Créer un fichier test.sh dans le dossier /srv/ avec le contenu suivant :
```
[melanie@TP3 ~]$ mkdir srv/
[melanie@TP3 ~]$ cd srv/
[melanie@TP3 srv]$ touch test.sh
[melanie@TP3 srv]$ ls
test.sh
```
```
[melanie@TP3 srv]$ cat test.sh
#!/bin/bash
#03/01/2023 - Marmande Melanie
# Simple testt script

echo "Connecté actuellement avec l'utilisateur $(whoami)."
```
```
[melanie@TP3 srv]$ chown melanie test.sh
[melanie@TP3 srv]$ chmod u+x test.sh
```
```
[melanie@TP3 srv]$ ./test.sh
Connecté actuellement avec l'utilisateur melanie.
```
```
[melanie@TP3 ~]$ srv/test.sh
Connecté actuellement avec l'utilisateur melanie.
```
## I. Script carte d'identité

Vous allez écrire un script qui récolte des informations sur le système et les affiche à l'utilisateur. Il s'appellera idcard.sh et sera stocké dans /srv/idcard/idcard.sh.
```
[melanie@TP3 ~]$ cd srv/
[melanie@TP3 srv]$ mkdir idcard/
[melanie@TP3 srv]$ cd idcard/
[melanie@TP3 idcard]$ touch idcard.sh
```
➜ Testez les commandes à la main avant de les incorporer au script.
➜ Ce que doit faire le script. Il doit afficher :

- le nom de la machine:
```
 echo $"Machine name : $(hostnamectl | head -1 | tr -s ' ' | cut -d' ' -f4)"
 ```
- le nom de l'OS de la machine:
source /etc/os-release
```
echo $"OS $(echo $PRETTY_NAME)"" and kernel version is $(uname -r)"
```
- l'adresse IP de la machine:
```
echo $"IP : $(ip a | grep -w 'inet' | tail -n 2 | awk '{print $2}')"
```
- l'état de la RAM:
```
[melanie@TP3 srv]$ echo $"RAM : $(free -h | grep "Mem" | awk '{print $4}')"" memory available on $(free -h | grep "Mem" | awk '{print $2}') total memory"
RAM : 1.4Gi memory available on 1.7Gi total memory
```

*tips pour moi*: la Ram est dans cette ordre: total, used, free, shared, buff/cache, available; et free=available // ex: awk '{ print $2; }' prints the second field of each line

- Disk:
```
[melanie@TP3 srv]$ echo $"Disk : $(df -h | grep 'G' | awk '{print $4}') space left"
Disk : 16G space left
```
*tips pour moi*: df -h –  l'espace disque sera affiché en Go (s'il est inférieur à 1 Go, il sera affiché en Mo ou même en o). df -m – Est utilisée pour afficher des informations sur l'utilisation du système de fichiers en Mo
// Disk dans cette ordre: Size, Used, available, use in %

- Processes:
```
PROC5="$(ps -eo command,%mem --sort=%mem | tail -n 5 | head -n 1)"

PROC4="$(ps -eo command,%mem --sort=%mem | tail -n 4 | head -n 1)"

PROC3="$(ps -eo command,%mem --sort=%mem | tail -n 3 | head -n 1)"

PROC2="$(ps -eo command,%mem --sort=%mem | tail -n 2 | head -n 1)"

PROC1="$(ps -eo command,%mem --sort=%mem | tail -n 1 | head -n 1)"

echo "Top 5 processes by RAM usage :
- $PROC1
- $PROC2
- $PROC3
- $PROC4
- $PROC5"
```
*tips pour moi*: -e  permet d'effectuer l'affichage de l'environnement de la commande actuellement en cours. -o permet d'indiquer qu'il faut mettre dans l'ordre spécifié la liste des processus.

- Ports:
```
echo "Listening ports : "
while read line
do
        protocol=$(echo "$line" | cut -d' ' -f1)
        port=$(echo "$line" |tr -s ' ' | cut -d' ' -f5 | cut -d':' -f2)
        services=$(echo "$line" | cut -d'"' -f2)
        echo " - $port $protocol : $services"
done <<< "$(ss -atunlpH4)"
```
- Cat pic:
```
file_name='catr'
curl --silent -o "${file_name}" https://cataas.com/cat

output="$(file $file_name)"

if [[ "${output}" == *JPEG* ]] ; then
type='jpg'
elif [[ "${output}" == *PNG* ]] ; then
type='png'
elif [[ "${output}" == *GIF* ]] ; then
type='gif'
fi
echo "Here is your random cat ./cat.${type}"
```
----
### **RENDU:**
```
[melanie@TP3 idcard]$ sudo ./idcard.sh
Machine name : TP3
OS Rocky Linux 9.0 (Blue Onyx) and kernel version is 5.14.0-70.30.1.el9_0.x86_64
IP : 10.0.2.15/24
192.168.56.103/24
RAM : 1.4Gi memory available on 1.7Gi total memory
Disk : 16G space left
Top 5 processes by RAM usage :
- /usr/bin/python3 -s /usr/sb  2.2
- /usr/sbin/NetworkManager --  1.0
- /usr/lib/systemd/systemd --  0.9
- /usr/lib/systemd/systemd --  0.7
- /usr/lib/systemd/systemd-jo  0.6
Listening ports :
 - 323 udp : chronyd
 - 22 tcp : sshd
Here is your random cat ./cat.jpg
```

📁 [idcard.sh](./idcard.sh)

## II. Script youtube-dl
sudo chown melanie:melanie (nomdufichier) --'chown = change owner'

Un petit script qui télécharge des vidéos Youtube. Vous l'appellerez yt.sh. Il sera stocké dans /srv/yt/yt.sh.

📁 Le script [/srv/yt/yt.sh](./yt.sh)

📁 Le fichier de log [/var/log/yt/download.log](download.log)


__🌞 Vous fournirez dans le compte-rendu, en plus du fichier, un exemple d'exécution avec une sortie, dans des balises de code__
```
[melanie@TP3 yt]$ ./yt.sh https://www.youtube.com/watch?v=ueJwZt3nmaQ
Video https://www.youtube.com/watch?v=ueJwZt3nmaQ was downloaded. File path : /srv/yt/downloads/Une vidéo de 1 seconde avec un fond noir/Une vidéo de 1 seconde avec un fond noir.mp4
[melanie@TP3 yt]$ ./yt.sh https://www.youtube.com/watch?v=ueJwZt3nmaQ
Already downloaded at : /srv/yt/downloads/Une vidéo de 1 seconde avec un fond noir
Video https://www.youtube.com/watch?v=ueJwZt3nmaQ was downloaded. File path : /srv/yt/downloads/Une vidéo de 1 seconde avec un fond noir/Une vidéo de 1 seconde avec un fond noir.mp4
```


## III. MAKE IT A SERVICE

```
[melanie@TP3 yt]$ ./yt-v2.sh
Already downloaded at : /srv/yt/downloads/SI LA VIDÉO DURE 1 SECONDE LA VIDÉO S'ARRÊTE
Video https://www.youtube.com/watch?v=jjs27jXL0Zs was downloaded. File path : /srv/yt/downloads/SI LA VIDÉO DURE 1 SECONDE LA VIDÉO S'ARRÊTE/SI LA VIDÉO DURE 1 SECONDE LA VIDÉO S'ARRÊTE.mp4
Video https://www.youtube.com/watch?v=a8DM-tD9w2I was downloaded. File path : /srv/yt/downloads/1 SECOND VIDEO (NOT CLICKBAIT)/1 SECOND VIDEO (NOT CLICKBAIT).mp4
Video https://www.youtube.com/watch?v=kvO_nHnvPtQ was downloaded. File path : /srv/yt/downloads/1 second black screen video/1 second black screen video.mp4
Video https://www.youtube.com/watch?v=jhFDyDgMVUI was downloaded. File path : /srv/yt/downloads/One Second Video/One Second Video.mp4
Video https://www.youtube.com/watch?v=Wch3gJG2GJ4 was downloaded. File path : /srv/yt/downloads/1 Second Video/1 Second Video.mp4
```
```
[melanie@TP3 yt]$ cat urls.txt
https://www.youtube.com/watch?v=YKsQJVzr3a8
https://www.youtube.com/watch?v=QohH89Eu5iM
https://www.youtube.com/watch?v=KCISG0phmbw
https://www.youtube.com/watch?v=QuV9iPaZTBU
https://www.youtube.com/watch?v=vDHtypVwbHQ
https://www.youtube.com/watch?v=1O0yazhqaxs
https://www.youtube.com/watch?v=5DEdR5lqnDE
https://www.youtube.com/watch?v=NRpNUi5e7Os
https://www.youtube.com/watch?v=QC8iQqtG0hg
```

```
[melanie@TP3 ~]$ sudo useradd yt

[melanie@TP3 ~]$ sudo chown  yt /srv/yt/url_file.txt
[melanie@TP3 ~]$ sudo chown  yt /srv/yt/yt-v2.sh 
[melanie@TP3 ~]$ sudo chown yt /var/log/yt/
[melanie@TP3 yt]$ sudo chown yt downloads

[melanie@TP3 ~]$ cat /etc/passwd | grep yt
yt:x:1001:1001::/home/yt:/bin/bash
[melanie@TP3 ~]$ sudo chown melanie /srv/yt/downloads/
[melanie@TP3 ~]$ sudo chown melanie /var/log/yt/download.log
[melanie@TP3 ~]$ sudo systemctl daemon-reload
[melanie@TP3 ~]$ sudo systemctl enable yt
[melanie@TP3 ~]$ sudo systemctl start yt
```

📁 Le script [/srv/yt/yt-v2.sh](./yt-v2.sh)

📁 Fichier [/etc/systemd/system/yt.service](./yt-service)

__🌞 Vous fournirez dans le compte-rendu, en plus des fichiers :__

- un systemctl status yt quand le service est en cours de fonctionnement
```
[melanie@TP3 ~]$ sudo systemctl status yt
● yt.service - Service pour lancer script qui telecharge urls youtube
     Loaded: loaded (/etc/systemd/system/yt.service; enabled; vendor preset: di>
     Active: active (running) since Thu 2023-01-12 19:16:14 CET; 10min ago
   Main PID: 672 (yt-v2.sh)
      Tasks: 2 (limit: 11116)
     Memory: 28.3M
        CPU: 6min 33.244s
     CGroup: /system.slice/yt.service
             ├─ 672 /bin/bash /srv/yt/yt-v2.sh
             └─2497 python /usr/local/bin/youtube-dl -qo "/srv/yt/downloads/Fun>

Jan 12 19:26:33 TP3 yt-v2.sh[672]: Video https://www.youtube.com/watch?v=YKsQJV>
^C
[melanie@TP3 ~]$ sudo systemctl status yt | grep active
     Active: active (running) since Thu 2023-01-12 19:16:14 CET; 10min ago
```

- un extrait de journalctl -xe -u yt
```
[melanie@TP3 ~]$ journalctl -xe -u yt 
Jan 12 19:28:46 localhost.localdomain systemd[1]: Started <Read a link file to permanently download youtube videos>.
░░ Subject: A start job for unit yt.service has finished successfully
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░ 
░░ A start job for unit yt.service has finished successfully.

░░ The job identifier is 1743

```
(pour moi: script yt-v2.sh à remodifier)