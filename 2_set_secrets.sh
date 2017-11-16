#!/bin/bash -e

api_key=$(docker-compose exec conjur rails r "print Credentials['cucumber:user:admin'].api_key")

command=$(cat <<EOF
conjur variable values add staging/myapp/database/username foo_staging_user
conjur variable values add staging/myapp/database/password "staging_$(openssl rand -hex 12)"
conjur variable values add staging/myapp/stripe/private_key "staging_$(openssl rand -hex 60)"

conjur variable values add production/myapp/database/username foo_production_user
conjur variable values add production/myapp/database/password "production_$(openssl rand -hex 12)"
conjur variable values add production/myapp/stripe/private_key "production_$(openssl rand -hex 60)"
EOF
)
docker-compose run --rm -e CONJUR_AUTHN_API_KEY=$api_key --entrypoint="bash -c '$command'" conjur_cli
