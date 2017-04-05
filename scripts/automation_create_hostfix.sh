#!/usr/bin/env bash
# Make sure you source the openrc file before executing this script locally
export INSTANCE_ID=$1
export APP_TAG=$2
export DNS_ENABLED=$3

if [[ $(echo $DNS_ENABLED | tr '[:upper:]' '[:lower:]') == "true" ]]
then	
  echo "no need to for hostfix because you have DNS enabled"
else
# HOSTFIX automation
HOSTFIX_AUTOMATION=hostsifx-auto
HOSTFIX_REPO=https://github.wdf.sap.corp/cc-chef-cookbooks/sapinst.git
HOSTFIX_REVISION=master
HOSTFIX_RUNLIST="recipe[sapinst::_hostsfix]"
HOSTFIX_ATTRIB_FILE=json/hostfix_attributes.json


# authentication using lyra to get token
lyra authenticate 2>&1 | tee tmp/token_export.sh

# export OS_TOKEN 
source tmp/token_export.sh

#Get automation list
lyra automation list 2>&1 | tee tmp/automation_list.txt

# Check if automation is already created
HOSTFIX_AUTOMATION_ID=`awk -v auto_name=$HOSTFIX_AUTOMATION '$4==auto_name {print $2}' tmp/automation_list.txt`

# Create HostFix automation only if not created already
if [[ -z "$HOSTFIX_AUTOMATION_ID" ]]; then
  lyra automation create chef --name=$HOSTFIX_AUTOMATION --repository=$HOSTFIX_REPO \
    --runlist=$HOSTFIX_RUNLIST  --timeout=3000 \
    --attributes-from-file=$HOSTFIX_ATTRIB_FILE --repository-revision=$HOSTFIX_REVISION --log-level=debug 2>&1 | tee tmp/automation_created.txt
  HOSTFIX_AUTOMATION_ID=`awk '$2=="id" {print $4}' tmp/automation_created.txt`
fi

#Add tag to server
lyra node tag add --node-id $INSTANCE_ID tag:$APP_TAG

# Execute automation
lyra automation execute --automation-id $HOSTFIX_AUTOMATION_ID  --selector='@identity="'$INSTANCE_ID'"' --watch 2>&1 | tee tmp/run_automation.txt

# Cleanup
#rm -f tmp/*.txt tmp/token_export.sh
fi

