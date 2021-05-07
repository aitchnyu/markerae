#!/bin/bash
docker build -t markeraeprod --target prod .
#docker build -t markerae .

if [[ -z "$POSTGRES_HOST" ]]
then
  echo looks like you didnt set any env variables
  exit 1
fi

if [[ $1 == "manage" ]]
then
  shift
  docker run --mount type=bind,source=/cloudsql,target=/cloudsql -e POSTGRES_DB="${POSTGRES_DB}" -e POSTGRES_USER="${POSTGRES_USER}" -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" -e POSTGRES_HOST="${POSTGRES_HOST}" -it markeraeprod /code/venv/bin/python3 /code/backend/manage.py "$@"
elif [[ $1 == "deploy" ]]
then
  echo foo
  # todo build container, upload static files, push to cloud run with env variables
#  echo "env_variables:" > backend/appenv.yaml
#  echo "  POSTGRES_DB: ${POSTGRES_DB}" >> backend/appenv.yaml
#  echo "  POSTGRES_USER: ${POSTGRES_USER}" >> backend/appenv.yaml
#  echo "  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}" >> backend/appenv.yaml
#  echo "  POSTGRES_HOST: ${POSTGRES_HOST}" >> backend/appenv.yaml
#  docker run --mount type=bind,source="$(pwd)",target=/code --mount type=bind,source=/cloudsql,target=/cloudsql -e POSTGRES_DB="${POSTGRES_DB}" -e POSTGRES_USER="${POSTGRES_USER}" -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" -e POSTGRES_HOST="${POSTGRES_HOST}" -it markerae /code/venv/bin/python3 /code/backend/manage.py collectstatic --noinput
#  docker run --mount type=bind,source="$(pwd)",target=/code --mount type=bind,source=/cloudsql,target=/cloudsql -e POSTGRES_DB="${POSTGRES_DB}" -e POSTGRES_USER="${POSTGRES_USER}" -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" -e POSTGRES_HOST="${POSTGRES_HOST}" -it markerae /code/venv/bin/python3 /code/backend/manage.py migrate
#  gcloud app deploy backend/app.yaml
else
  echo unknown command
fi