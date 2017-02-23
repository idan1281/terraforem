#!/usr/bin/env bash
# Make sure you source the openrc file before executing this script locally

read SRV_NAME < srv_name
AUTOMATION_NAME=create_file_2
AUTOMATION_REPO=https://github.wdf.sap.corp/c5240533/rcntree.git
REPO_REVISION=master
RUNLIST="recipe[rcntree::create_file]"
ATTRIB_FILE="/Users/c5240533/dev/terraform/s4h_terraform/scripts/attributes.json"
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

# Execute automation
lyra automation execute --automation-id $AUTOMATION_ID --selector '@hostname="app"' --watch 2>&1 | tee tmp/run_automation.txt

# Cleanup
rm -f tmp/*.txt tmp/token_export.sh
