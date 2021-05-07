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
ADD ./append_bashrc_dev.sh /tmp/append_bashrc_dev.sh
RUN cat /tmp/append_bashrc_dev.sh >> ~/.bashrc
EXPOSE 8000

FROM ubuntu:18.04 as jsbase
RUN mkdir /code
WORKDIR /code/vueapp
RUN apt-get update && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs

FROM jsbase as jsdev
ADD ./append_bashrc_jsdev.sh /tmp/append_bashrc_jsdev.sh
RUN cat /tmp/append_bashrc_jsdev.sh >> ~/.bashrc

FROM jsbase as jsprod
ENV WEBPACK_DIST ./webpack-dist
COPY vueapp/ ./
CMD ./node_modules/.bin/vue-cli-service build --target wc-async --inline-vue --name webcomponents 'src/*.vue'
CMD ls ./webpack-dist

# todo copy static files from prev js stage
FROM base as prod
COPY backend/requirements.txt requirements.txt
RUN pip3 install -r requirements.txt && \
    pip3 install gunicorn==20.1.0
# This is to allow manage.py commands
ENV POSTGRES_DB=fake POSTGRES_USER=fake POSTGRES_PASSWORD=fake POSTGRES_HOST=fake
COPY backend/ ./
CMD python3 manage.py collectstatic --noinput
COPY --from=jsprod webpack-dist static/app/webpack-dist
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app