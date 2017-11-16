#!/bin/bash -e

env=$1

# Application layer has the secrets-users role
if [ "$env" = "staging" ] || [ "$env" = "production" ]; then
  api_key=$(docker-compose exec conjur rails r "print Credentials['cucumber:user:admin'].api_key")
  echo '------- Applying myapp policy to staging root policy ----------'
  docker-compose run --rm -e CONJUR_AUTHN_API_KEY=$api_key conjur_cli \
  policy load --replace "$env" /src/policy/apps/myapp.yml
else
  echo "'$env' is not valid option.  Please choose either 'staging' or 'production'"
fi
