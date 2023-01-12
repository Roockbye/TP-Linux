[melanie@TP3 yt]$ cat yt-v2.sh
#!/bin/bash
#11/01/2023 - Marmande Melanie
#Update script qui telecharge des vidéos Youtube pour service

if [[ ! -f /var/log/yt/download.log ]]
then
  echo "File does not exist"
  exit 0
fi

if [[ ! -f /srv/yt/urls.txt ]]
then
  echo "File does not exist"
  exit 0
fi

while true
do
url=$(cat /srv/yt/urls.txt | head -n 1 | grep 'https://www.youtube.com/watch?v=')
$(sed -i '1d' /srv/yt/urls.txt)
title="$(youtube-dl -e "${url}")"
path="/srv/yt/downloads/${title}"
description="${path}/description.txt"
if [[ -d ${path} ]]; then
        echo "Already downloaded at : ${path}"
else
        mkdir "${path}"
fi
if [[ -d ${description} ]]; then
        echo "Already downloaded at : ${description}"
else
        touch "${description}"
fi
youtube-dl -qo  "${path}/${title}.mp4" "${url}" 2> /dev/null
youtube-dl --get-description "${url}" > "${description}"
date="$(echo "[$(date '+%D %T')]")"
echo "${date} Video ${url} was downloaded. File path : ${path}/${title}.mp4" >> /var/log/yt/download.log
echo "Video ${url} was downloaded. File path : ${path}/${title}.mp4"
sleep 2
done
