#!/usr/bin/env bash
# Make sure you source the openrc file before executing this script locally
export INSTANCE_ID=$1
export DB_TAG=$2

AUTOMATION_NAME=s4h-db
AUTOMATION_REPO=https://github.wdf.sap.corp/c5215768/hana.git
REPO_REVISION=master
RUNLIST="recipe[hana::install-s4h-db-cal]"
ATTRIB_FILE=json/test_db_attributes.json

# authentication using lyra to get token
lyra authenticate 2>&1 | tee tmp/token_export.sh

# export OS_TOKEN 
source tmp/token_export.sh

#Get automation list
lyra automation list 2>&1 | tee tmp/automation_list.txt

# Check if automation is already created
AUTOMATION_ID=`awk -v auto_name=$AUTOMATION_NAME '$4==auto_name {print $2}' tmp/automation_list.txt`

# Create automation only if not created already
if [[ -z "$AUTOMATION_ID" ]]; then
  lyra automation create chef --name=$AUTOMATION_NAME --repository=$AUTOMATION_REPO \
    --runlist=$RUNLIST  --timeout=3000 \
    --attributes-from-file=$ATTRIB_FILE --repository-revision=$REPO_REVISION --timeout=36000 --log-level=debug  2>&1 | tee tmp/automation_created.txt
  AUTOMATION_ID=`awk '$2=="id" {print $4}' tmp/automation_created.txt`
fi


#Add tag to server
#lyra node tag add --node-id $INSTANCE_ID name:s4h-db
lyra node tag add --node-id $INSTANCE_ID name:$DB_TAG
# Execute automation
lyra automation execute --automation-id $AUTOMATION_ID --selector='@identity="'$INSTANCE_ID'"' --watch 2>&1 | tee tmp/run_automation.txt

# Cleanup
#rm -f tmp/*.txt tmp/token_export.sh
