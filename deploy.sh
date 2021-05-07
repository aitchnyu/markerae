#!/bin/bash
# todo copy appenv.yaml from sample file
echo "  POSTGRES_DB: ${POSTGRES_DB}" >> backend/appenv.yaml
echo "  POSTGRES_USER: ${POSTGRES_USER}" >> backend/appenv.yaml
echo "  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}" >> backend/appenv.yaml
echo "  POSTGRES_HOST: ${POSTGRES_HOST}" >> backend/appenv.yaml
#/code/venv/bin/python3 /code/backend/manage.py collectstatic --noinput
docker build -t markerae .
# todo run proxy here
# here local postgres host
#docker run --mount type=bind,source="$(pwd)",target=/code -e POSTGRES_DB="${POSTGRES_DB}" -e POSTGRES_USER="${POSTGRES_USER}" -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" -e POSTGRES_HOST="${POSTGRES_HOST}" -it markerae ls -la
docker run --mount type=bind,source="$(pwd)",target=/code --mount type=bind,source=/cloudsql,target=/cloudsql -e POSTGRES_DB="${POSTGRES_DB}" -e POSTGRES_USER="${POSTGRES_USER}" -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" -e POSTGRES_HOST="${POSTGRES_HOST}" -it markerae /code/venv/bin/python3 /code/backend/manage.py showmigrations
#docker run --mount type=bind,source="$(pwd)",target=/code -it markerae /code/venv/bin/python3 /code/backend/manage.py showmigrations