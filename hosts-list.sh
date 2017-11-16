#!/bin/bash -e
clear
echo "Layers:"
conjur list -i -k layer | jq .
echo
echo "Hosts:"
conjur list -i -k host | jq .
