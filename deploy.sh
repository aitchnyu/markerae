#!/bin/bash

if [[ -z "$PROJECT_ID" ]]
then
  echo It appears you are not running this in GCloud Shell.
  exit 1
fi
if [[ -z "$POSTGRES_HOST" ]]
then
  echo It appears you didnt set necessary env variables
  exit 1
fi

docker build --target prod --tag "gcr.io/${PROJECT_ID}/my-image" .

if [[ $1 == "manage" ]]
then
  shift
  docker run --mount type=bind,source=/cloudsql,target=/cloudsql -e POSTGRES_DB="${POSTGRES_DB}" -e POSTGRES_USER="${POSTGRES_USER}" -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" -e POSTGRES_HOST="${POSTGRES_HOST}" -it "gcr.io/${PROJECT_ID}/my-image" python3 manage.py "$@"
elif [[ $1 == "deploy" ]]
then
   docker run --mount type=bind,source="$(pwd)",target=/hostpwd \
      -it "gcr.io/${PROJECT_ID}/my-image" \
      bash -c "python3 manage.py collectstatic --noinput && cp -R static /hostpwd/static"
   gsutil -m rm gs://${STATIC_BUCKET}/**
   gsutil -m cp -Z -r static/** "gs://${STATIC_BUCKET}/"
   sudo rm -r static
   docker push "gcr.io/${PROJECT_ID}/my-image"
   gcloud_deploy () {
      gcloud run deploy "${SERVICE_NAME}" \
        --image "gcr.io/${PROJECT_ID}/my-image:latest" \
        --platform managed \
        --region "${REGION}" \
        --max-instances 5 \
        --cpu 1 \
        --memory 256Mi \
        --timeout 10 \
        --concurrency 10 \
        --ingress all \
        --allow-unauthenticated \
        --set-cloudsql-instances "${POSTGRES_HOST}"\
        --update-env-vars POSTGRES_DB="${POSTGRES_DB}" \
        --update-env-vars POSTGRES_USER="${POSTGRES_USER}" \
        --update-env-vars POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
        --update-env-vars POSTGRES_HOST="${POSTGRES_HOST}" \
        --update-env-vars ALLOWED_HOSTS="$1" \
        --update-env-vars STATIC_URL="https://storage.googleapis.com/${STATIC_BUCKET}/"
   }
  gcloud run services describe "${SERVICE_NAME}" --platform managed --region "${REGION}"
  if [[ $? != 0 ]]
  then
    echo first deploy
    # Are you unable to find the service? That means its a first deploy
    gcloud_deploy fake_host
    URL=$(gcloud run services describe "${SERVICE_NAME}" --platform managed --region "${REGION}" --format json | jq -r '.status.address.url')
    # todo below lines in case Gcloud has no domain names
#    while true
#    do
#      URL=$(gcloud run services describe "${SERVICE_NAME}" --platform managed --region "${REGION}" --format json | jq -r '.status.address.url')
#      echo "url ${URL}"
#      if [[ $URL != "null" ]]
#       then break
#      fi
#      echo "Waiting for url"
#      sleep 5
#    done
    gcloud_deploy "${URL}"
  else
      echo subsqeuent deploy
      URL=$(gcloud run services describe "${SERVICE_NAME}" --platform managed --region "${REGION}" --format json | jq -r '.status.address.url')
      gcloud_deploy "${URL}"
  fi
else
  echo unknown command
fi