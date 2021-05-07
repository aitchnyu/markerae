# Marker Project for Cloud Run


https://cloud.google.com/sql/docs/mysql/connect-admin-proxy#install
```
git clone https://github.com/aitchnyu/markerae.git
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