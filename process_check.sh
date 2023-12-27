#!/bin/bash

NGINX_PS_COUNT=$(ps aux | grep nginx | grep -v "\(root\|grep\)" | wc -l)

echo "nginx processes: ${NGINX_PS_COUNT}"

if [ "${NGINX_PS_COUNT}" -ne 0 ]; then
    echo "nginx is running"
else
    echo "not running nginx"
    sudo systemctl start nginx
    sleep 1

    NGINX_PS_COUNT=$(ps aux | grep nginx | grep -v "\(root\|grep\)" | wc -l)
    if [ "${NGINX_PS_COUNT}" -ne 0 ]; then
        echo "nginx is running"
    else
        echo "not running nginx"
    fi
fi
