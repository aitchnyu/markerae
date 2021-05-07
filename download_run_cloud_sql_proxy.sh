apt install wget
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /tmp/cloud_sql_proxy
chmod +x /tmp/cloud_sql_proxy
/tmp/cloud_sql_proxy -instances=marker-311206:asia-southeast1:pg=tcp:0.0.0.0:5432 &