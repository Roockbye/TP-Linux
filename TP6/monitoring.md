# Module 4 : Monitoring

__🌞 Installer Netdata__

```
[melanie@db ~]$ dnf update
```
```
[melanie@db ~]$ dnf install epel-release -y
```
```
[melanie@db ~]$ sudo dnf -y install wget
```
```
[melanie@db ~]$ wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh
```

```
[melanie@db ~]$ sudo systemctl start netdata
```
```
[melanie@db ~]$ sudo systemctl enable netdata
```
```
[melanie@db ~]$ sudo systemctl status netdata
● netdata.service - Real time performance monitoring
     Loaded: loaded (/usr/lib/systemd/system/netdata.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2023-02-07 11:34:25 CET; 2min 57s ago
   Main PID: 2929 (netdata)
      Tasks: 72 (limit: 11072)
     Memory: 120.8M
        CPU: 10.697s
     CGroup: /system.slice/netdata.service
             ├─2929 /usr/sbin/netdata -P /run/netdata/netdata.pid -D
             ├─2932 /usr/sbin/netdata --special-spawn-server
             ├─3126 /usr/libexec/netdata/plugins.d/apps.plugin 1
             ├─3130 bash /usr/libexec/netdata/plugins.d/tc-qos-helper.sh 1
             ├─3136 /usr/libexec/netdata/plugins.d/ebpf.plugin 1
             └─3137 /usr/libexec/netdata/plugins.d/go.d.plugin 1

Feb 07 11:34:26 db.linux.tp5 ebpf.plugin[3136]: thread created with task id 3193
Feb 07 11:34:26 db.linux.tp5 ebpf.plugin[3136]: set name of thread 3193 to EBPF SHM
Feb 07 11:34:26 db.linux.tp5 ebpf.plugin[3136]: thread created with task id 3186
Feb 07 11:34:26 db.linux.tp5 ebpf.plugin[3136]: set name of thread 3186 to EBPF SYNC
Feb 07 11:34:26 db.linux.tp5 ebpf.plugin[3136]: thread created with task id 3192
Feb 07 11:34:26 db.linux.tp5 ebpf.plugin[3136]: set name of thread 3192 to EBPF OOMKILL
Feb 07 11:34:26 db.linux.tp5 ebpf.plugin[3136]: thread created with task id 3188
Feb 07 11:34:26 db.linux.tp5 ebpf.plugin[3136]: set name of thread 3188 to EBPF MOUNT
Feb 07 11:34:26 db.linux.tp5 ebpf.plugin[3136]: thread with task id 3192 finished
Feb 07 11:34:27 db.linux.tp5 apps.plugin[3126]: Using now_boottime_usec() for uptime (dt is 3 ms)
```

```
[melanie@db ~]$ sudo firewall-cmd --permanent --add-port=19999/tcp
success
[melanie@db ~]$ sudo firewall-cmd --reload
success
[melanie@db ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 3306/tcp 19999/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

```
[melanie@db ~]$ ss -alpnt | grep 19999
LISTEN 0      4096         0.0.0.0:19999      0.0.0.0:*
LISTEN 0      4096            [::]:19999         [::]:*
```

__🌞 Une fois Netdata installé et fonctionnel, déterminer :__

- l'utilisateur sous lequel tourne le(s) processus Netdata
```
[melanie@db ~]$ ps -ef | grep netdata
root        2697       1  0 11:33 ?        00:00:00 gpg-agent --homedir /var/cache/dnf/netdata-edge-a383c484584e0b14/pubring --use-standard-socket --daemon
root        2699    2697  0 11:33 ?        00:00:00 scdaemon --multi-server --homedir /var/cache/dnf/netdata-edge-a383c484584e0b14/pubring
root        2740       1  0 11:33 ?        00:00:00 gpg-agent --homedir /var/cache/dnf/netdata-repoconfig-3ca68ffb39611f32/pubring --use-standard-socket --daemon
root        2742    2740  0 11:33 ?        00:00:00 scdaemon --multi-server --homedir /var/cache/dnf/netdata-repoconfig-3ca68ffb39611f32/pubring
netdata     2929       1  2 11:34 ?        00:00:31 /usr/sbin/netdata -P /run/netdata/netdata.pid -D
netdata     2932    2929  0 11:34 ?        00:00:00 /usr/sbin/netdata --special-spawn-server
netdata     3126    2929  0 11:34 ?        00:00:10 /usr/libexec/netdata/plugins.d/apps.plugin 1
netdata     3130    2929  0 11:34 ?        00:00:01 bash /usr/libexec/netdata/plugins.d/tc-qos-helper.sh 1
root        3136    2929  0 11:34 ?        00:00:02 /usr/libexec/netdata/plugins.d/ebpf.plugin 1
netdata     3137    2929  1 11:34 ?        00:00:17 /usr/libexec/netdata/plugins.d/go.d.plugin 1
melanie     3626    1523  0 11:56 pts/0    00:00:00 grep --color=auto netdata
```
- si Netdata écoute sur des ports
```
[melanie@db ~]$ ss -alpnt | grep 19999
LISTEN 0      4096         0.0.0.0:19999      0.0.0.0:*
LISTEN 0      4096            [::]:19999         [::]:*
```
- comment sont consultables les logs de Netdata

```
[melanie@db ~]$ journalctl -xeu netdata
Feb 07 11:34:25 db.linux.tp5 netdata[2929]: CONFIG: cannot load cloud config '/var/lib/netdata/cloud.d/cloud.conf'. Running with internal >
Feb 07 11:34:25 db.linux.tp5 netdata[2929]: 2023-02-07 11:34:25: netdata INFO  : MAIN : CONFIG: cannot load cloud config '/var/lib/netdata>
Feb 07 11:34:25 db.linux.tp5 netdata[2929]: 2023-02-07 11:34:25: netdata INFO  : MAIN : Found 0 legacy dbengines, setting multidb diskspac>
Feb 07 11:34:25 db.linux.tp5 netdata[2929]: 2023-02-07 11:34:25: netdata INFO  : MAIN : Created file '/var/lib/netdata/dbengine_multihost_>
Feb 07 11:34:25 db.linux.tp5 netdata[2929]: Found 0 legacy dbengines, setting multidb diskspace to 256MB
Feb 07 11:34:25 db.linux.tp5 netdata[2929]: Created file '/var/lib/netdata/dbengine_multihost_size' to store the computed val
```

__🌞 Configurer Netdata pour qu'il vous envoie des alertes__

```
[melanie@web netdata]$ cat health_alarm_notify.conf | grep discord
# discord (discord.com) global notification options

# multiple recipients can be given like this:
#                  "CHANNEL1 CHANNEL2 ..."

# enable/disable sending discord notifications
SEND_DISCORD="YES"

# Create a webhook by following the official documentation -
# https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1073951843450900561/qiBeEBRrujElkAEcJnv_8FB6_BdAHrtSw_DzysaK61vEQ0Mzq7AYHMh6mCmacDpJFg-n"

# if a role's recipients are not configured, a notification will be send to
# this discord channel (empty = do not send a notification for unconfigured
# roles):
DEFAULT_RECIPIENT_DISCORD="alarms"
```

__🌞 Vérifier que les alertes fonctionnent__

```
[melanie@web ~]$ sudo dnf install stress
```

```
[melanie@web netdata]$ sudo systemctl restart netdata
```

```
[melanie@web ~]$ stress -c 5 -m 5
stress: info: [2801] dispatching hogs: 5 cpu, 0 io, 5 vm, 0 hdd
```