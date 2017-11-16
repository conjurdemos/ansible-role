#!/bin/bash -e
clear
echo "Groups:"
conjur list -i -k group | jq .
echo
echo "Users:"
conjur list -i -k user | jq .
