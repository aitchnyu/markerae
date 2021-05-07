#!/bin/bash

if [[ -z "$PROJECT_ID" ]]
then
  echo looks like you are not running this in GCloud Shell
  exit 1
fi
if [[ -z "$POSTGRES_HOST" ]]
then
  echo looks like you didnt set any env variables
  exit 1
fi

docker build --target prod --tag "gcr.io/${PROJECT_ID}/my-image" .

if [[ $1 == "manage" ]]
then
  shift
  docker run --mount type=bind,source=/cloudsql,target=/cloudsql -e POSTGRES_DB="${POSTGRES_DB}" -e POSTGRES_USER="${POSTGRES_USER}" -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" -e POSTGRES_HOST="${POSTGRES_HOST}" -it "gcr.io/${PROJECT_ID}/my-image" python3 manage.py "$@"
elif [[ $1 == "deploy" ]]
then
   docker run --mount type=bind,source="$(pwd)",target=/hostpwd -it "gcr.io/${PROJECT_ID}/my-image" bash -c "python3 manage.py collectstatic --noinput && cp -R static /hostpwd/static"
   gsutil -m rm gs://${STATIC_BUCKET}/**
   gsutil -m cp -Z -r static/** "gs://${STATIC_BUCKET}/"
   sudo rm -r static
   docker push "gcr.io/${PROJECT_ID}/my-image"
  # todo push to cloud run with env variables
  gcloud run deploy dd --image "gcr.io/${PROJECT_ID}/my-image:latest" --platform managed --region "${REGION}" --max-instances=5
else
  echo unknown command
fi