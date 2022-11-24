# TP1 : Are you dead yet ?

## II. Feu 🔥

#### __🌞 Trouver au moins 4 façons différentes de péter la machine:__
<br>

## __Méthode 1:__ 🔍
Je me suis déplacée dans les dossiers avec ``cd`` et ``ls``

Et j'ai décidé de déplacer un fichier dans un autre dossier :

```sudo mv /boot/grub2/  /var/lock/```

grub2 est le chargeur de boot par défaut (contient aussi le fichier de rescue donc rescue non excécutable ou difficilement). Il est chargé de lancer l’OS et permet le choix quand plusieurs OS sont installés sur une même machine.
Si c'est dernier est changé d'emplacement le démarrage sera impossible car le chemin des fichiers racines n'est plus correct.

📷 [crash1](./crash%201.png)

## __Méthode 2:__ 💾
Celle-là est une commande dangereuse et irréversible puisque nous effacons la partition du disque : 

```sudo dd if=/dev/zero of=/dev/sda5```

Et le reboot est inefficace.

La commande dd peut permettre de faire une image du dique, ou encore de cloner le disque mais aussi de remettre toutes ces données à zéro

if=FICHIER lire FICHIER au lieu de l’entrée standard (stdin)

of=FICHIER écrire dans FICHIER au lieu de la sortie standard (stdout)

Dans le cas d’un disque, ce sera donc : /dev/sda, /dev/sdb

Avec une partition de disque : /dev/sda1, /dev/sda2, /dev/sdb1

📷 [crash2](./crash%202.png)

### __Dans le même style:__ ➿

Celui-ci écrasera notre MBR avec des données (pseudo)-aléatoire :

```dd if=/dev/urandom of=/dev/sda bs=512 count=1crash ```

bs=OCTETS lire et écrire jusqu’à OCTETS octets à la fois (défaut: 512)

count=N ne copier que N blocs d’entrée

MBR --> =Le Master Boot Record (secteur principal de démarrage) c'est le premier secteur d'un disque dur, il possède des informations permettant d'identifier l'emplacement et le statut d'un système d'exploitation afin de le charger dans la mémoire principale ou la mémoire vive.

📷 [crash3](./crash%203.png)

## __Méthode 3:__ 🔌

Cette commande provoque un déni de service local qui affecte le socket de notifications, c'est une faille au niveau du systemd

```NOTIFY_SOCKET=/run/systemd/notify systemd-notify ""```

On ne peux plus redémarrer correctement le système et les connections ne se font plus.

Un socket permet la communication inter processus (IPC - Inter Processus Communication) afin de permettre à divers processus de communiquer aussi bien sur une même machine qu'à travers un réseau TCP/IP.

NOTIFY_SOCKET est défini par le gestionnaire de service pour l'état et la notification d'achèvement du démarrage. 

systemd-notify peut être appelé par des scripts démons pour informer le système init des changements d'état. Il peut être utilisé pour envoyer des informations arbitraires, codées dans une liste de chaînes de type bloc d'environnement. Il peut aussi être utilisé pour la notification d'achèvement de démarrage (notre cas ici)

📷 [crash4](./crash%204.png)

## __Méthode 4:__ 🔨

Suppression de bash :

```sudo rm -f /usr/bin/bash``` 

Impossible de reboot. 

Bash est un interpréteur de commande (shell) compatible sh qui exécute les commandes lues depuis l'entrée standard, ou depuis un fichier. Si ce dernier est supprimer plus aucunes commandes ne pourra être excécuté 

Message d'erreur: 
System has not been booted with systemd as init system. Can't operate
Failed to connect to bus: host down.
Failed to talk to init daemon

📷 [crash5](./crash%205.png)

### __Dans le même style:__ ➿


```sudo rm -rf / --no-preserve-root```

Le dossier /sys/firmware/efi/efivars/ a probalement été supprimé à cause de cette commande.

Cet emplacement stocke les scripts et les informations utilisés pour démarrer l’ordinateur. Si il disparait l'ordi ne peux plus se lancer.

--> amène à un rescue grub

📷 [crash6](./crash%206.png)


## __Méthode bis:__ (pas ouf ouf) 🔇

- fork bomb (classique): 💣

```:(){ :|:& };:```   

le même appel de fonction dans un format plus lisible:

```forkbomb(){ forkbomb | forkbomb & }; forkbomb```

: est le nom de la fonction -->forkbomb

:|: appelle la fonction elle-même et génère un autre processus

& met le processus en arrière-plan, de sorte qu’il ne puisse pas être tué aussi facilement

; marque la fin de la fonction

: Appelle à nouveau la fonction

📷 [crash7](./crash%207.png)

- System Request 🔒

```echo c > /proc/sysrq-trigger```

SysRq ou « System Request" permet d’envoyer des instructions spécifiques directement au noyau Linux.
On fait un echo 1 ou activer le sysrq, echo o pour eteindre le systeme et echo c pour le faire planter







