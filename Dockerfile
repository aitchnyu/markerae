FROM ubuntu:18.04 as base
# CMD fails on prod target for some strange Cloud Run behavior on 20.04 https://stackoverflow.com/questions/61989516/running-gcloud-run-deploy-from-inside-cloud-build-results-in-error
ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
# This was asking dialog for tzdata
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv libpq-dev python3-dev && \
    apt-get install -y binutils libproj-dev gdal-bin

FROM base as dev
ADD ./bash_start.sh /tmp/bash_start.sh
RUN cat /tmp/bash_start.sh >> ~/.bashrc
EXPOSE 8000

FROM base as prod
COPY backend/requirements.txt requirements.txt
RUN pip3 install -r requirements.txt && \
    pip3 install gunicorn==20.1.0
ENV POSTGRES_DB=fake POSTGRES_USER=fake POSTGRES_PASSWORD=fake POSTGRES_HOST=fake
COPY backend/ ./
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app

# todo later
FROM ubuntu:20.04 as js
RUN mkdir /code
WORKDIR /code
RUN apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs