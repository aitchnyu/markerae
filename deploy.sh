#!/bin/bash
echo "  POSTGRES_DB: ${POSTGRES_DB}" >> backend/appenv.yaml
echo "  POSTGRES_USER: ${POSTGRES_USER}" >> backend/appenv.yaml
echo "  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}" >> backend/appenv.yaml
echo "  POSTGRES_HOST: ${POSTGRES_HOST}" >> backend/appenv.yaml
#/code/venv/bin/python3 /code/backend/manage.py collectstatic --noinput
docker build -t markerae .
docker run --mount type=bind,source="$(pwd)",target=/code -it markerae /bin/bash
docker run --mount type=bind,source="$(pwd)",target=/code -it markerae /code/venv/bin/python3 /code/backend/manage.py showmigrations