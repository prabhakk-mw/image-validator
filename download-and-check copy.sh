#!/bin/bash

# Read all releases from releases.txt into a variable as a space-separated list
RELEASES=$(tr '\n' ' ' < releases.txt)
sudo mkdir -p /mnt/manifests
sudo chown -R prabhakk /mnt/manifests

for RELEASE in $RELEASES; do

    echo "Processing release: $RELEASE"
    RELEASE_INSTALL_DIR="/mnt/matlab/${RELEASE}"
    MANIFEST_FILE="/mnt/manifests/${RELEASE}_Linux.enc.manifest"
    
    # Check if the release directory already exists
    if [ -d "$RELEASE_INSTALL_DIR" ]; then
        echo "Release directory already exists: $RELEASE_INSTALL_DIR"
    else
        ./mpm download --release=$RELEASE --destination=$RELEASE_INSTALL_DIR --products=$(cat ~/${RELEASE%U*}.txt)
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
done


# ./mpm download --release=R2025aU0 --destination=/home/prabhakk/R2025aU0 --products=`cat /home/prabhakk/R2025a.txt`
# find /home/prabhakk/R2025aU0 -name "*.enc" > R2025aU0_Linux.enc.manifest 
# mwsign -c 1.0.2 -v -m R2025aU0_Linux.enc.manifest 

# ./mpm download --release=<release> --destination=</full/path/to/destination> --products=<product1> ... <productN>