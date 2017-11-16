#!/bin/bash -e
clear
echo "Variable IDs:"
conjur list -i -k variable | jq .[]
echo
echo "Variable values:"

variable_dictionary=""
variable_resource_ids=$(conjur list -i -k variable | jq -r .[].id | grep myapp | sort)

while read line; do
   variable_id=$(echo ${line} | sed -e "s/^.*:variable://")
   variable_kv="\"$variable_id\": \"$(conjur variable value ${variable_id})\""

   if [[ -z $variable_dictionary ]]; then
      variable_dictionary="$variable_kv"
   else
      variable_dictionary="$variable_dictionary,$variable_kv"
   fi
done <<< "$(echo -e "$variable_resource_ids")"

echo "{$variable_dictionary}" | jq .
