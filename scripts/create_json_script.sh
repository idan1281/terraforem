#!/bin/bash
read VAR1 VAR2 < srv_name
echo $VAR1

#create attribute file

cat <<EOF > scripts/attributes.json
{
  "rcntree": {
    "db_server": "$VAR1"
   }
}     

EOF
