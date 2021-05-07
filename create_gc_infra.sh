if [[ $1 == "bucket" ]]
then
  gsutil mb "gs://${2}"
  gsutil defacl set public-read "gs://${2}"
elif [[ $1 == "db" ]]
then
  echo Not implemented
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
else
  echo Command to create GCS bucket and Cloud sql db.
  echo ./create_gc_infra.sh bucket [your bucket name]
  echo ./create_gc_infra.sh db [instance name] [region] [root password]
fi