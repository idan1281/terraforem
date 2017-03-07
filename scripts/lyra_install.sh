#!/bin/bash
# Install lyra client on local workstation
if [[ "$WORKSTATION_OS" == "linux" ]]; then
 BIN_PATH=/usr/sbin
 LYRA_BINARY_URL=https://github.wdf.sap.corp/monsoon/lyra-cli/releases/download/v20160922.2/lyra_linux
elif [[ "$WORKSTATION_OS" == "darwin" ]]; then
 BIN_PATH=/Users/c5240533/bin # for Mac Workstation
 LYRA_BINARY_URL=https://github.wdf.sap.corp/monsoon/lyra-cli/releases/download/v20160922.2/lyra_darwin
else
 echo "Unknown Workstation  OS !!"
fi
export BIN_PATH
echo $BIN_PATH

echo "Lyra Version: $(lyra version)"
TMP_DIR=$PWD/tmp

if [ ! -d "$TMP_DIR" ]; then
  mkdir $TMP_DIR
  echo "$TMP_DIR is created...."
else
  echo "$TMP_DIR is previously created. Skipping...."
fi

usage()
{
  echo `basename $0`: ERROR: $* 1>&2
  echo usage: `basename $0` 'instance-id  instance-type'
}
case $1 in
  "") usage;
  exit 1
esac

case $2 in
  "") usage;
  exit 1
esac

export INSTANCE_ID=$1
export INSTANCE_OS=$2

if [[ -z $OS_USERNAME || -z $OS_PASSWORD || -z $OS_PROJECT_NAME || -z $OS_AUTH_URL || -z $INSTANCE_ID || -z $INSTANCE_OS ]]; then
  if [ -z $OS_USERNAME ];then
    echo "OS_USERNAME is missing"
  fi
  if [ -z $OS_PASSWORD ];then
    echo "OS_PASSWORD is missing"
  fi
  if [ -z $OS_AUTH_URL ];then
    echo "OS_AUTH_URL is missing"
  fi
  if [ -z $OS_PROJECT_NAME ];then
    echo "OS_PROJECT_NAME is missing"
  fi
  if [ -z $INSTANCE_ID ];then
  echo "INSTANCE_ID is missing"
    usage
    exit 1
  fi
    if [ -z $INSTANCE_OS ];then
        echo "INSTANCE_OS is missing"
    usage
    exit 1
    fi
fi

# Install lyra client on local workstation
if [ -z "$LYRA_BINARY_URL" ];then
  echo "LYRA_BINARY_URL is missing"
fi

if [ -x "$BIN_PATH/lyra" ];then
  echo "Lyra is already downloaded"
else
  wget -O $BIN_PATH/lyra $LYRA_BINARY_URL
  chmod +x $BIN_PATH/lyra
fi

# Clean up previously created INS_ scripts
#rm -f $TMP_DIR/INS_*.sh*

lyra node install --install-format=$INSTANCE_OS 2>&1 | tee $TMP_DIR/INS_$INSTANCE_ID.sh
chmod +x $TMP_DIR/INS_$INSTANCE_ID.sh
# Make those scripts to use sudo
sed -i -e 's/curl/sudo curl/g' $TMP_DIR/INS_$INSTANCE_ID.sh
sed -i -e 's/chmod/sudo chmod/g' $TMP_DIR/INS_$INSTANCE_ID.sh
sed -i -e 's@/opt/arc/arc init@sudo /opt/arc/arc init@g' $TMP_DIR/INS_$INSTANCE_ID.sh
