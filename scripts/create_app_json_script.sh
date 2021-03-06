#!/bin/bash
export DB_TAG=$1
export APP_TAG=$2
export SAPERP_VERSION=$3

#create attribute file

cat > json/demo_app_attributes.json << EOF
{
  "saperp": {
    "version": "$SAPERP_VERSION",
    "db": {
      "sid": "H50",
      "instid": "02",
      "systempw": "Start1234"
    },
    "ascs": {
      "sid": "S4H",
      "instanceid": "00"
    },
    "pas": {
      "instanceid": "01"
    },
    "aas": {
      "instanceid": "02"
    },
    "master": {
      "password": "Start1234"
    },
    "sidadm": {
      "password": "Start1234"
    },
    "dbca": {
      "password": "Start1234"
    },
    "dbsid": {
      "password": "Start1234"
    },
    "webadm": {
      "password": "Start1234"
    },
    "hana": {
      "revision": "82"
    },
    "kernel": {
      "patch_version": "50"
    }
  },
   "sap-lvm": {
     "filesystem": "ext3",
     "sapdata_size": "220G",
     "user_sap_sid_size": "10G",
     "sapinst_size": "60G"
 },
   "sapinst": {
     "db_tag": "$DB_TAG",
     "app_tag": "$APP_TAG"
   }
}     

EOF
