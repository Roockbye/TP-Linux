#!/bin/bash
#06/01/2023 - Melanie Marmande
#script carte d'identite- recolte des infos sur le systeme et les affichent a l'utilisateur

echo $"Machine name : $(hostnamectl | head -1 | tr -s ' ' | cut -d' ' -f4)"
source /etc/os-release
echo $"OS $(echo $PRETTY_NAME)"" and kernel version is $(uname -r)"
echo $"IP : $(ip a | grep -w 'inet' | tail -n 2 | awk '{print $2}')"
echo $"RAM : $(free -h | grep "Mem" | awk '{print $4}')"" memory available on $(free -h | grep "Mem" | awk '{print $
echo $"Disk : $(df -h | grep 'G' | awk '{print $4}') space left"
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

echo "Listening ports : "
while read line
do
        protocol=$(echo "$line" | cut -d' ' -f1)
        port=$(echo "$line" |tr -s ' ' | cut -d' ' -f5 | cut -d':' -f2)
        services=$(echo "$line" | cut -d'"' -f2)
        echo " - $port $protocol : $services"
done <<< "$(ss -atunlpH4)"

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
