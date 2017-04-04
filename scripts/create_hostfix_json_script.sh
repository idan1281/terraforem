#!/bin/bash
export DB_HOST=$1
export APP_HOST=$2
export DNS_ENABLED=$3

#create attribute file only if DNS_ENABLED from terraform is not set to true

if [[ $(echo $DNS_ENABLED | tr '[:upper:]' '[:lower:]') == "true" ]]
then
  echo no need for hostfix because you have DNS enabled
else
cat > json/hostfix_attributes.json << EOF
{
    "sapinst": {
        "db_tag": "$DB_HOST",
        "app_tag": "$APP_HOST"
    }
}
EOF
fi
