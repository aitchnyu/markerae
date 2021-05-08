#!/bin/bash
if [[ $1 == "start" ]]
then
  if [[ ! -f ~/cloud_sql_proxy ]]; then
    echo Downloading google cloud sql proxy
    wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O ~/cloud_sql_proxy
    chmod +x ~/cloud_sql_proxy
  fi
  sudo mkdir -p /cloudsql
  sudo chown $USER:$USER /cloudsql
  nohup ~/cloud_sql_proxy -instances="$PROJECT_ID:$REGION:$POSTGRES_INSTANCE" -dir=/cloudsql &
  PROXY_PID=$! # This is accessed as a global. This must be killed later.
  sleep 5 # Wait or psql may be unable to connect immediately
  echo "cloud_sql_proxy started at PID $PROXY_PID"
else
  kill "$(ps ax | grep "instances=$PROJECT_ID:$REGION:$POSTGRES_INSTANCE" | head -n1 | awk '{print $1;}')"
fi