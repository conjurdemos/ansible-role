#!/bin/bash -e
clear
echo "Groups:"
conjur list -i -k group
echo
echo "Users:"
conjur list -i -k user
