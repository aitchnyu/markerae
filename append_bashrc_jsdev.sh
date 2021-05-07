# This is appended at container build time

if [ ! -d node_modules ]; then
  npm install
fi

suggest () {
  read -ei "$*"
  history -s "$REPLY"
  fc -s
}

COUNT=$(ps ax | grep "vue-cli-service" | wc -l)
if [[ "$COUNT" == "1" ]];
then
  echo "Suggested command: hit enter or ctrl+c"
  suggest "./node_modules/.bin/vue-cli-service build --watch --target wc-async --inline-vue --name webcomponents 'src/*.vue'"
fi