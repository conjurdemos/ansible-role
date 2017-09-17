#!/bin/bash -e
clear
echo "Layers:"
conjur list -i -k layer
echo
echo "Hosts:"
conjur list -i -k host
