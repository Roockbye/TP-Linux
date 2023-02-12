#!/bin/bash
# Melanie Marmande - 12/02/2023
# Script backup
fileName="nextcloud_$(date +%Y%m%d%H%M%S).tar.gz"
tar -czf /srv/backup/$fileName /var/www/tp5_nextcloud/
echo "Filename : $fileName saved in /srv/backup"