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
ADD ./append_bashrc_dev.sh /tmp/tmp.sh
RUN cat /tmp/tmp.sh >> ~/.bashrc
EXPOSE 8000

FROM ubuntu:18.04 as jsbase
RUN apt-get update && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs

FROM jsbase as jsdev
RUN mkdir /code
WORKDIR /code/vueapp
ENV WEBPACK_DIST=../backend/app/static/app/webpack-dist
ADD ./append_bashrc_jsdev.sh /tmp/tmp.sh
RUN cat /tmp/tmp.sh >> ~/.bashrc

FROM jsbase as jsprod
ENV WEBPACK_DIST ./webpack-dist
COPY vueapp/ ./
RUN npm install && ./node_modules/.bin/vue-cli-service build --target wc-async --inline-vue --name webcomponents 'src/*.vue'

FROM base as prod
COPY backend/requirements.txt requirements.txt
RUN pip3 install -r requirements.txt && \
    pip3 install gunicorn==20.1.0
COPY backend/ ./
COPY --from=jsprod webpack-dist app/static/app/webpack-dist
RUN python3 manage.py collectstatic --noinput
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app