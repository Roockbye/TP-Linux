# Module 3 : Fail2Ban

__🌞 Faites en sorte que :__

```
[melanie@db ~]$ sudo dnf install epel-release -y
Complete!
```

```
[melanie@db ~]$ sudo dnf install fail2ban

Complete!
```

- si quelqu'un se plante 3 fois de password pour une co SSH en moins de 1 minute, il est ban

```
[melanie@db ~]$ sudo systemctl status fail2ban
× fail2ban.service - Fail2Ban Service
     Loaded: loaded (/usr/lib/systemd/system/fail2ban.service; enabled; vendor >
     Active: failed (Result: exit-code) since Tue 2023-02-07 10:41:01 CET; 11s >
   Duration: 120ms
       Docs: man:fail2ban(1)
    Process: 1584 ExecStartPre=/bin/mkdir -p /run/fail2ban (code=exited, status>
    Process: 1585 ExecStart=/usr/bin/fail2ban-server -xf start (code=exited, st>
   Main PID: 1585 (code=exited, status=255/EXCEPTION)
        CPU: 121ms

Feb 07 10:41:01 db.linux.tp5 systemd[1]: Starting Fail2Ban Service...
Feb 07 10:41:01 db.linux.tp5 systemd[1]: Started Fail2Ban Service.
Feb 07 10:41:01 db.linux.tp5 fail2ban-server[1585]: 2023-02-07 10:41:01,502 fai>
Feb 07 10:41:01 db.linux.tp5 fail2ban-server[1585]: 2023-02-07 10:41:01,570 fai>
Feb 07 10:41:01 db.linux.tp5 fail2ban-server[1585]: 2023-02-07 10:41:01,571 fai>
Feb 07 10:41:01 db.linux.tp5 systemd[1]: fail2ban.service: Main process exited,>
Feb 07 10:41:01 db.linux.tp5 systemd[1]: fail2ban.service: Failed with result '>
```

```
[melanie@db fail2ban]$ sudo cp jail.conf jail.local
```
```
[melanie@db fail2ban]$ sudo vi jail.local
```
 modif que j'ai faites dans le fichier de conf:
 ```
[Default]
findtime= 1m
maxretry=3
bantime=10m
[sshd]
enabled=true
```




```
[melanie@db fail2ban]$ sudo systemctl enable fail2ban
Created symlink /etc/systemd/system/multi-user.target.wants/fail2ban.service → /usr/lib/systemd/system/fail2ban.service.
```
```
[melanie@db fail2ban]$ sudo systemctl start fail2ban
```
```
[melanie@db fail2ban]$ sudo systemctl status fail2ban
● fail2ban.service - Fail2Ban Service
     Loaded: loaded (/usr/lib/systemd/system/fail2ban.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2023-02-07 10:54:33 CET; 6s ago
       Docs: man:fail2ban(1)
    Process: 2253 ExecStartPre=/bin/mkdir -p /run/fail2ban (code=exited, status=0/SUCCESS)
   Main PID: 2254 (fail2ban-server)
      Tasks: 5 (limit: 11072)
     Memory: 12.1M
        CPU: 159ms
     CGroup: /system.slice/fail2ban.service
             └─2254 /usr/bin/python3 -s /usr/bin/fail2ban-server -xf start

Feb 07 10:54:33 db.linux.tp5 systemd[1]: Starting Fail2Ban Service...
Feb 07 10:54:33 db.linux.tp5 systemd[1]: Started Fail2Ban Service.
Feb 07 10:54:33 db.linux.tp5 fail2ban-server[2254]: 2023-02-07 10:54:33,118 fail2ban.configreader   [2254]: WARNING 'allowipv6' not define>
Feb
```
```
[melanie@db fail2ban]$ ssh melanie@10.105.1.11
The authenticity of host '10.105.1.11 (10.105.1.11)' can't be established.
ED25519 key fingerprint is SHA256:uwtR01X+dwQ39Jx9k3PIvPgVBMTrVMY4LdbuhPCMhXc.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.105.1.11' (ED25519) to the list of known hosts.
melanie@10.105.1.11's password:
Permission denied, please try again.
melanie@10.105.1.11's password:
Permission denied, please try again.
melanie@10.105.1.11's password:
melanie@10.105.1.11: Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).
```
- vérifiez que ça fonctionne en vous faisant ban
```
[melanie@db fail2ban]$ sudo fail2ban-client status
Status
|- Number of jail:      1
`- Jail list:   sshd
```
- utilisez une commande dédiée pour lister les IPs qui sont actuellement ban
```
[melanie@db fail2ban]$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     0
|  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned: 0
   |- Total banned:     0
   `- Banned IP list:

```
- afficher l'état du firewall, et trouver la ligne qui ban l'IP en question
```
[melanie@db fail2ban]$ sudo firewall-cmd --list-all
public
  target: default
  icmp-block-inversion: no
  interfaces:
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
```

- lever le ban avec une commande liée à fail2ban
```
[melanie@db fail2ban]$ sudo fail2ban-client unban --all
0
```
ou

```
fail2ban-client set sshd unbanip 10.105.1.11

[melanie@db fail2ban]$ sudo !!
sudo fail2ban-client set sshd unbanip 10.105.1.11
0
```
