if [[ $1 == "bucket" ]]
then
  gsutil mb "gs://${2}"
  gsutil defacl set public-read "gs://${2}"
elif [[ $1 == "db" ]]
then
  echo Not implemented
else
  echo Command to create GCS bucket and Cloud sql db.
  echo ./create_gc_infra.sh bucket [your bucket name]
  echo ./create_gc_infra.sh db [your db name]
fi