# This is appended at container build time
alias clean-data="rm -rf /code/venv && rm -rf /code/pgdata && rm -rf /code/vueapp/node_modules && rm -rf /code/backend/static /code/backend/app/static/app/webpack-dist"

if [ ! -d /code/venv ]; then
  python3 -m venv /code/venv
  /code/venv/bin/pip3 install -r /code/backend/requirements.txt
fi

/code/venv/bin/python3 /code/backend/manage.py migrate

suggest () {
  read -ei "$*"
  history -s "$REPLY"
  fc -s
}

COUNT=$(ps ax | grep "manage.py runserver" | wc -l)
if [[ "$COUNT" == "1" ]];
then
  echo "Suggested command: hit enter or ctrl+c"
  suggest "/code/venv/bin/python3 /code/backend/manage.py runserver 0.0.0.0:8000"
fi