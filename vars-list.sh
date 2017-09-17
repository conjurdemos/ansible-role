#!/bin/bash -e
clear
echo "Variable IDs:"
conjur list -i -k variable
echo
echo "Variable values:"
echo "staging/database/username: " $(conjur variable value staging/myapp/database/username)
echo "staging/database/password: " $(conjur variable value staging/myapp/database/password)
echo "production/database/username: " $(conjur variable value production/myapp/database/username)
echo "production/database/password: " $(conjur variable value production/myapp/database/password)

