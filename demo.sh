#!/bin/bash -e

function finish {
  echo 'Removing demo environment'
  echo '---'
  docker-compose down -v
  rm -rf conjur.pem
}
trap finish EXIT

function main() {
  docker-compose up --build -d --scale myapp_staging=2 --scale myapp_production=4 conjur conjur_cli ansible conjur-proxy-nginx myapp_staging myapp_production

  fetch_ssl_cert

  docker-compose logs -f conjur myapp_staging myapp_production
}

function fetch_ssl_cert {
  docker exec $(docker-compose ps -q conjur-proxy-nginx) cat cert.crt > conjur.pem
}

main
