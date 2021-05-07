#!/bin/bash

if [[ ! -f ~/cloud_sql_proxy ]]; then
    echo Downloading google cloud sql proxy
    wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O ~/cloud_sql_proxy
    chmod +x ~/cloud_sql_proxy
fi

sudo mkdir -p /cloudsql
sudo chown $USER:$USER /cloudsql