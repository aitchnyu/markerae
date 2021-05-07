apt install wget
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy
# todo not in tmp
chmod +x cloud_sql_proxy
nohup cloud_sql_proxy -instances=marker-311206:asia-southeast1:pg=tcp:0.0.0.0:5432 &