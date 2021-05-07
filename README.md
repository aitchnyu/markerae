# Marker Project for Cloud Run

```
gcloud cloud-shell ssh --authorize-session
git clone https://github.com/aitchnyu/markerae.git
cd markerae
./create_gc_infra.sh db [region] [root password]
./create_gc_infra.sh bucket [static bucket]
```

Install Cloud sql proxy
```
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O ~/cloud_sql_proxy
chmod +x ~/cloud_sql_proxy"
```

```
cd markerae 
sudo mkdir /cloudsql && sudo chown $USER:$USER /cloudsql
export POSTGRES_DB=<db> POSTGRES_USER=<user> POSTGRES_PASSWORD=<password> POSTGRES_HOST=/cloudsql/<connection-string> PROJECT_ID=<project-id>
~/cloud_sql_proxy -instances=<connection-string> -dir=/cloudsql &
```

```
~/markerae$ ./deploy.sh manage showmigrations
~/markerae$ ./deploy.sh manage migrate
~/markerae$ ./deploy.sh manage addsuperuser
~/markerae$ ./deploy.sh deploy
```