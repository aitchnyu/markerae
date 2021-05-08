#!/bin/bash
if [[ ! -f ~/cloud_sql_proxy ]]; then
  echo Downloading google cloud sql proxy
  wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O ~/cloud_sql_proxy
  chmod +x ~/cloud_sql_proxy
fi
sudo mkdir -p /cloudsql
sudo chown $USER:$USER /cloudsql
echo before nohup
nohup ~/cloud_sql_proxy -instances="$PROJECT_ID:$REGION:$POSTGRES_INSTANCE" -dir=/cloudsql &
PROXY_PID=$! # This is accessed as a global. This must be killed later.
echo before sleep
sleep 5 # Wait or psql may be unable to connect immediately
echo $PROXY_PID