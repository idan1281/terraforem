#!/bin/bash
export DB_HOST=$1
export APP_HOST=$2

#create attribute file

cat > json/hostfix_attributes.json << EOF
{
    "sapinst": {
        "db_tag": "$DB_HOST",
        "app_tag": "$APP_HOST"
    }
}
EOF
