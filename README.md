# Marker Project for Cloud Run

![example workflow](https://github.com/aitchnyu/markerae/actions/workflows/push.yml/badge.svg)

Create a Project on GCP. We get an id like `project-311206`

Login to Cloud Shell.
```
gcloud cloud-shell ssh --authorize-session
```

One time
```
git clone https://github.com/aitchnyu/markerae.git
```

To use Google's container registry
```gcloud auth configure-docker```

Create DB and Bucket. Investigate scripts to find system requirements.
```
cd markerae
./create_gc_infra.sh db [instance name] [region] [root password]
```

```
export SITE=[site name]
# Infra details
export PROJECT_ID=[project id generated]
export REGION=[region, asia-south1 for Mumbai]
export SERVICE_NAME=markerae
# Resources
export POSTGRES_DB=[db name]
export POSTGRES_USER=postgres
export  POSTGRES_PASSWORD=[password]
export  POSTGRES_INSTANCE=[instance name]
```

```
cd markerae
./create_gc_infra.sh db [instance name] [region] [root password]
./deploy_on_gc.sh manage build
./deploy_on_gc.sh manage showmigrations
./deploy_on_gc.sh manage migrate
./deploy_on_gc.sh manage createsuperuser
./deploy_on_gc.sh deploy
```

## Technologies used
- Django with Postgis
- Leaflet maps with Mapbox
- Vue with webcomponents target
- Selenium for functional testing
- Github actions for CI with integration tests
- Docker compose for dev environment
- Google Cloud Run, Cloud SQL, Cloud Shell for deployment
- Cloudflare for CDN
