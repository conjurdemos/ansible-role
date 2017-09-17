#!/bin/bash -e
api_key=$(docker-compose exec conjur rails r "print Credentials['cucumber:user:admin'].api_key")

docker-compose run --rm -e CONJUR_AUTHN_API_KEY=$api_key conjur_cli
