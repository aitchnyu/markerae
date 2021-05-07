#!/bin/bash

GMETADATA_ADDR=`dig +short metadata.google.internal`
if [[ "${GMETADATA_ADDR}" == "" ]]; then
    echo "It appears you are not running this in Cloud shell"
    exit 1
fi
# todo make this a loop
if [[ -z "$POSTGRES_INSTANCE" ]]
then
  echo "It appears you didnt set necessary env variables"
  exit 1
fi

if [[ $1 == "build" ]]
then
  docker pull "gcr.io/${PROJECT_ID}/my-image"
  docker build --target prod --tag "gcr.io/${PROJECT_ID}/my-image" .
  docker push "gcr.io/${PROJECT_ID}/my-image"
elif [[ $1 == "manage" ]]
then
  shift
  # todo this script should wait the needful time and return the pid
  ./ensure_gc_sql_proxy.sh
  nohup ~/cloud_sql_proxy -instances="$PROJECT_ID:$REGION:$POSTGRES_INSTANCE" -dir=/cloudsql &
  PROXY_PID=$!
  sleep 5 # Wait or psql may be unable to connect immediately
  # From https://stackoverflow.com/a/18389184 check if POSTGRES_DB exists and then create POSTGRES_DB if needed.
  echo "SELECT 'CREATE DATABASE ${POSTGRES_DB}' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${POSTGRES_DB}')\gexec" | PGPASSWORD="$POSTGRES_PASSWORD" psql -h "/cloudsql/$PROJECT_ID:$REGION:$POSTGRES_INSTANCE" -U postgres
  PGPASSWORD="$POSTGRES_PASSWORD" psql -h "/cloudsql/$PROJECT_ID:$REGION:$POSTGRES_INSTANCE" -d "${POSTGRES_DB}" -U postgres -c 'create extension if not exists postgis;'
  docker run --mount type=bind,source=/cloudsql,target=/cloudsql \
    -e POSTGRES_DB="${POSTGRES_DB}" \
    -e POSTGRES_USER="${POSTGRES_USER}" \
    -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
    -e POSTGRES_HOST="/cloudsql/$PROJECT_ID:$REGION:$POSTGRES_INSTANCE" \
    -it "gcr.io/${PROJECT_ID}/my-image" python3 manage.py "$@"
  kill "${PROXY_PID}"
elif [[ $1 == "deploy" ]]
then
   docker pull "gcr.io/${PROJECT_ID}/my-image"
   gcloud_deploy () {
      # The comma in the value "foo.com,bar.com" is syntax error for gcloud dict-type args, so specify ";" as delimiter for ALLOWED_HOSTS
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
        --set-cloudsql-instances $POSTGRES_INSTANCE\
        --update-env-vars DEBUG="false" \
        --update-env-vars POSTGRES_DB="${POSTGRES_DB}" \
        --update-env-vars POSTGRES_USER="${POSTGRES_USER}" \
        --update-env-vars POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
        --update-env-vars POSTGRES_HOST="/cloudsql/$PROJECT_ID:$REGION:$POSTGRES_INSTANCE" \
        --update-env-vars ALLOWED_HOSTS="^;^$1" \
        --update-env-vars STATIC_URL="/static-$(openssl rand -hex 12)/"
   }
   hostnames() {
     # We get a {"status": {"address": {"url": "https://example.appspot.com"...}...}...}
     CLOUD_RUN_HOSTNAME=`gcloud run services describe "${SERVICE_NAME}" --platform managed --region "${REGION}" --format json | jq -r '.status.address.url' | cut -c9-`
     if [[ $SITE ]]
     then
       echo "$CLOUD_RUN_HOSTNAME,$SITE"
     else
       echo $CLOUD_RUN_HOSTNAME
     fi
   }
   gcloud run services describe "${SERVICE_NAME}" --platform managed --region "${REGION}"
   # Is gcloud unable to find the service and returned a nonzero exit code? That means we have to do a first deploy with a fake hostname
   if [[ $? != 0 ]]
   then
     echo Creating service
     gcloud_deploy "fakehostname"
     gcloud_deploy "`hostnames`"
   else
     echo Updating service
     echo "site is `hostnames`"
     gcloud_deploy "`hostnames`"
  fi
else
  echo Run Django manage.py command
  echo ./deploy_on_gc.sh manage [rest of manage command]
  printf "\n"
  echo deploy to Cloud Run
  echo ./deploy_on_gc.sh deploy
fi