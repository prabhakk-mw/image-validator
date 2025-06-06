#!/bin/bash

RELEASE=$1

echo "Processing release: $RELEASE"
RELEASE_INSTALL_DIR=`pwd`"/matlab/${RELEASE}"
MANIFESTS=`pwd`"/manifests"
mkdir -p $MANIFESTS
MANIFEST_FILE=${MANIFESTS}/${RELEASE}"_Linux.enc.manifest"

# Check if the release directory already exists
if [ -d "$RELEASE_INSTALL_DIR" ]; then
    echo "Release directory already exists: $RELEASE_INSTALL_DIR"
else
    ./mpm download --release=$RELEASE --destination=$RELEASE_INSTALL_DIR --products=$(cat ./inputfiles/${RELEASE%U*}.txt)
    echo "Downloaded release: $RELEASE to $RELEASE_INSTALL_DIR"
fi

find $RELEASE_INSTALL_DIR -name "*.enc" > $MANIFEST_FILE
echo "Created manifest file: $MANIFEST_FILE"

mwsign -c 1.0.2 -v -m $MANIFEST_FILE > $MANIFEST_FILE.mwsign_result
if [ $? -eq 0 ]; then
    echo "Signature verification successful for $MANIFEST_FILE"
    # delete the folder /mnt/${RELEASE} if the signature verification is successful
    rm -rf $RELEASE_INSTALL_DIR
    echo "Deleted folder: $RELEASE_INSTALL_DIR"
else
    echo "Signature verification failed for $MANIFEST_FILE"
fi
echo "----------------------------------------"
