#!/bin/bash

machinename=$(cat "/proc/sys/kernel/hostname")
echo "Machine Name : ${machinename}"

source /etc/os-release
kernel_version=$(uname -r)
echo "OS ${PRETTY_NAME} and kernel version is ${kernel_version}"

ip=$(ip a | grep '2:' -A 2 | grep inet | tr -s ' ' | cut -d' ' -f3)
echo "IP : ${ip}"

freeram=$(grep MemFree /proc/meminfo | tr -s ' ' | cut -d ':' -f2)
totalram=$(grep MemTotal /proc/meminfo | tr -s ' ' | cut -d ':' -f2)
echo "RAM :${freeram} memory available on${totalram} totaly ram"

diskleft=$(df -h | grep /dev/sda | tr -s ' ' | cut -d ' ' -f4)
echo "Disk : ${diskleft} space left"

process=$(ps -eo cmd --sort=-%mem | head -6 | tr -s ' ' | cut -d '/' -f4 | cut -d ' ' -f1| sed -n '1d;p')
echo "Top 5 processes by Ram usage :"
echo " - ${process}"

echo "Listening ports :"
sudo ss -lntup | while read -r line; do
  if [[ $line == *"State"* ]]; then
	continue
  fi
  port=$(echo  "$line" | awk '{print $5}'|cut -d':' -f2)
  if [[ -n $port ]]; then
    types=$(echo "$line" | awk '{print $1}')
    program=$(echo "$line" | awk '{print $7}'|cut -d'"' -f2)
    echo "- ${port} ${types} : ${program}"
  fi
done

echo "PATH directories :"
path=$PATH
for (( i=0; i<${#path}; i++ )); do
    char="${path:$i:1}"
    
    if [[ "$char" == ":" ]]; then
        
        echo -n "- ${path:0:$i}"
        echo   
    path="${path:$((i+1))}"
        i=0
    fi
done
echo "- $path"

image_url=$(curl -s 'https://api.thecatapi.com/v1/images/search' | cut -d '"' -f8)
echo "Here is your random cat: ${image_url}"

