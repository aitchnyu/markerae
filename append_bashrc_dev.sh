# This is appended at container build time
# todo why need this?
alias dmanage="/code/venv/bin/python3 /code/backend/manage.py"
alias clean-data="rm -rf /code/venv && rm -rf /code/pgdata && rm -rf /code/vueapp/node_modules && rm -rf /code/backend/static /code/backend/app/static/app/webpack-dist" # todo static files too

if [ ! -d /code/venv ]; then
  python3 -m venv /code/venv
  /code/venv/bin/pip3 install -r /code/backend/requirements.txt
fi

#if [ ! -d /code/vueapp/node_modules ]; then
#  vnpm install
#fi

# TODO make this overridable, check only if first migrate
dmanage migrate

suggest () {
  read -ei "$*"
  history -s "$REPLY"
  fc -s
}

COUNT=$(ps ax | grep "manage.py runserver" | wc -l)
if [[ "$COUNT" == "1" ]];
then
  echo "Suggested command: hit enter or ctrl+c"
  suggest "dmanage runserver 0.0.0.0:8000"
fi