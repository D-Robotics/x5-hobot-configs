#!/bin/bash

for i in {1..10}; do
    if country=$(curl -s --max-time 3 https://ipapi.co/country); then
        echo "Network online, starting apt source update."
        echo "Detected country: $country"

        if [ "$country" = "CN" ]; then
            echo "Switching to Tsinghua mirror..."
            sed -i '/^deb .*ports.ubuntu.com/ s|http://ports.ubuntu.com/|http://mirrors4.tuna.tsinghua.edu.cn/ubuntu-ports/|g' /etc/apt/sources.list
            sed -i '/^deb .*packages.ros.org/ s|http://packages.ros.org/|http://mirrors4.tuna.tsinghua.edu.cn/|g' /etc/apt/sources.list.d/ros2.list
        else
            echo "Switching to official ports.ubuntu.com ..."
            sed -i '/^deb .*mirrors4.tuna.tsinghua.edu.cn/ s|http://mirrors4.tuna.tsinghua.edu.cn/ubuntu-ports/|http://ports.ubuntu.com/|g' /etc/apt/sources.list
            sed -i '/^deb .*mirrors4.tuna.tsinghua.edu.cn/ s|http://mirrors4.tuna.tsinghua.edu.cn/|http://packages.ros.org/|g' /etc/apt/sources.list.d/ros2.list
        fi

        # Run apt update after switching source
        #echo "Running apt update..."
        #apt update

        exit 0
    else
        echo "Network not ready, retrying ($i)..."
        sleep 2
    fi
done

echo "Failed to detect network, aborting."

exit 1
