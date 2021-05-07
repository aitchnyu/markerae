# Marker Project for Cloud Run

Create a Project on GCP. We get an id like `project-311206`

Each time
```
gcloud cloud-shell ssh --authorize-session
```

One time
```
git clone https://github.com/aitchnyu/markerae.git
```

Create DB and Bucket. Investigate scripts to find system requirements.
```
cd markerae
./create_gc_infra.sh db [region] [root password]
./create_gc_infra.sh bucket [static bucket]
```

```
# Infra details
export PROJECT_ID=[project id generated]
export REGION=[region, asia-south1 for Mumbai]
export SERVICE_NAME=markerae
# Resources
export POSTGRES_DB=postgres
export POSTGRES_USER=postgres
export  POSTGRES_PASSWORD=password
#export  POSTGRES_HOST=/cloudsql/marker-311206:asia-southeast1:marker
export  POSTGRES_INSTANCE=marker
export STATIC_BUCKET=marker-static-jj
```

```
cd markerae
./create_gc_infra.sh db [region] [root password]
./create_gc_infra.sh bucket [static bucket]
./deploy_on_gc.sh manage showmigrations
./deploy_on_gc.sh manage migrate
./deploy_on_gc.sh manage createsuperuser
./deploy_on_gc.sh deploy
```
