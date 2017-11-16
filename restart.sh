#!/bin/bash -e

cd ansible

env=$1

if [ "$env" = "staging" ] || [ "$env" = "production" ]; then
  echo '--------- Run Playbook ------------'
  HFTOKEN="$hf_token" APP_ENV="$env" ansible-playbook "playbooks/myapp-restart.yml"

else
  echo "'$env' is not valid option.  Please choose either 'staging' or 'production'"
fi
