#!/usr/bin/env bash
# Make sure you source the openrc file before executing this script locally
export INSTANCE_ID=$1
export APP_TAG=$2

# APP automation
AUTOMATION_NAME=s4h-app
AUTOMATION_REPO=https://github.wdf.sap.corp/c5215768/saperp.git
REPO_REVISION=master
#RUNLIST="recipe[saperp::install-s4h-app-cal]recipe[sap-lvm::application]"
RUNLIST="recipe[sap-lvm::application],recipe[saperp::install-s4h-app-cal]"
ATTRIB_FILE=json/test_app_attributes.json

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
    --attributes-from-file=$ATTRIB_FILE --repository-revision=$REPO_REVISION --log-level=debug 2>&1 | tee tmp/automation_created.txt
  AUTOMATION_ID=`awk '$2=="id" {print $4}' tmp/automation_created.txt`
fi

#Add tag to server
lyra node tag add --node-id $INSTANCE_ID name:$APP_TAG

# Execute automation
lyra automation execute --automation-id $HOSTFIX_AUTOMATION_ID  --selector='@identity="'$INSTANCE_ID'"' --watch 2>&1 | tee tmp/run_automation.txt

# Cleanup
# rm -f tmp/*.txt tmp/token_export.sh
