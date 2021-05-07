FROM ubuntu:20.04
ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
# This was asking dialog for tzdata
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv libpq-dev python3-dev && \
    apt-get install -y binutils libproj-dev gdal-bin && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs
ADD ./bash_start.sh /tmp/bash_start.sh
RUN cat /tmp/bash_start.sh >> ~/.bashrc
EXPOSE 8000
