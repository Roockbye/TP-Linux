[Unit]
Description=Backup nextcloud

[Service]
Type=oneshot
ExecStart=/srv/tp6_backup.sh
User=backup