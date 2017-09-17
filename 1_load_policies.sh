#!/bin/bash -e

api_key=$(docker-compose exec conjur rails r "print Credentials['cucumber:user:admin'].api_key")

echo '--------------- Creating user/group hiearchy ------------------'
docker-compose run --rm -e CONJUR_AUTHN_API_KEY=$api_key conjur_cli \
  policy load --replace root /src/policy/users.yml

echo '------ Creating staging and production root policies ----------'
docker-compose run --rm -e CONJUR_AUTHN_API_KEY=$api_key conjur_cli \
  policy load root /src/policy/policy.yml

echo '------- Applying myapp policy to staging root policy ----------'
docker-compose run --rm -e CONJUR_AUTHN_API_KEY=$api_key conjur_cli \
  policy load staging /src/policy/apps/myapp.yml

echo '------ Applying myapp policy to production root policy --------'
docker-compose run --rm -e CONJUR_AUTHN_API_KEY=$api_key conjur_cli \
  policy load production /src/policy/apps/myapp.yml

echo '-- Granting secrets_managers role for staging and production --'
docker-compose run --rm -e CONJUR_AUTHN_API_KEY=$api_key conjur_cli \
  policy load root /src/policy/apps/myapp_grants.yml
