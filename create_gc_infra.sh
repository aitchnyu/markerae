if [[ $1 == "bucket" ]]
then
  gsutil mb "gs://${2}"
  gsutil defacl set public-read "gs://${2}"
elif [[ $1 == "db" ]]
then
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
elif [[ $1 == "test" ]]
then
  sudo mkdir -p /cloudsql && sudo chown $USER:$USER /cloudsql
  CONNECTION_NAME=$(gcloud sql instances describe test --format json | jq -r '.connectionName')
  nohup ~/cloud_sql_proxy -instances="${CONNECTION_NAME}" -dir=/cloudsql &
  PROXY_PID=$!
  echo $PROXY_PID
  ps ax | grep proxy
  PGPASSWORD=testpasswd psql -h "/cloudsql/$CONNECTION_NAME" -d postgres -U postgres -c 'create extension postgis;'
  kill "${PROXY_PID}"
else
  echo Command to create GCS bucket and Cloud sql db.
  echo ./create_gc_infra.sh bucket [your bucket name]
  echo ./create_gc_infra.sh db [instance name] [region] [root password]
fi