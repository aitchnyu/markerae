#!/bin/bash

if [[ $1 == "bucket" ]]
then
  # Create bucket and make objects publically downloadable
  gsutil mb "gs://${2}"
  gsutil defacl set public-read "gs://${2}"
elif [[ $1 == "db" ]]
then
  # Create Postgres db and enable postgis extension
#  ./ensure_gc_sql_proxy.sh
  gcloud sql instances create $2 \
    `# Not HA` \
    --availability-type zonal \
    --database-version POSTGRES_13 \
    --region $3 \
    --root-password $4 \
    --storage-auto-increase \
    --storage-size 10 \
    --storage-type SSD \
    --tier db-f1-micro
#  sudo mkdir -p /cloudsql && sudo chown $USER:$USER /cloudsql
#  CONNECTION_NAME=$(gcloud sql instances describe $2 --format json | jq -r '.connectionName')
#  nohup ~/cloud_sql_proxy -instances="${CONNECTION_NAME}" -dir=/cloudsql &
#  PROXY_PID=$!
#  sleep 5 # Wait or psql may be unable to connect immediately
#  PGPASSWORD=$4 psql -h "/cloudsql/$CONNECTION_NAME" -d postgres -U postgres -c 'create extension if not exists postgis;'
#  kill "${PROXY_PID}"
else
  echo Command to create GCS bucket and Cloud sql db.
  echo ./create_gc_infra.sh bucket [your bucket name]
  echo ./create_gc_infra.sh db [instance name] [region] [root password]
fi