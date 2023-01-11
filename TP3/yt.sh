#!/bin/bash
#09/01/2023 - Marmande Melanie
#Script qui telecharge des vidéos Youtube
url="${1}"
title="$(youtube-dl --get-filename -o "%(title)s" "${url}")"
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
