#!/bin/bash

# Hubic configuration

CONFIGFILE=/root/.s3ql/authinfo2
chmod 600 $CONFIGFILE

if [ "$S3QL_BACKEND_OPTIONS" ]; then
    BACKEND_OPTIONS="--backend-options $S3QL_BACKEND_OPTIONS"
fi

# max-cache-entries (check ulimit -n to be at least 100 bigger than this)

if [ -z "$S3QL_CACHE_ENTRIES"]; then
    S3QL_CACHE_ENTRIES=17000
fi

# mountpoint

if [ -z "$S3QL_MOUNT" ]; then
    S3QL_MOUNT=/mnt/hubic
fi

# cachesize (size is in KB)

if [ -z "$S3QL_CACHESIZE" ]; then
    # 10 GB:
    S3QL_CACHESIZE=$(( 10 * 1024 * 1024 ))
fi

# metadata-upload-interval (Size is in seconds)

if [ -z "$S3QL_METADATA_INTERVAL" ]; then
    S3QL_METADATA_INTERVAL=$(( 6 * 60 * 60 ))
fi

# storage-url (swift://<hostname>:<port>/<container>)

if [ "$S3QL_STORAGE_URL" ]; then
    sed -i "s#^storage-url:#storage-url: swift://$S3QL_STORAGE_URL#" $CONFIGFILE
else
    S3QL_STORAGE_URL=hubicgate:80/default
fi

# backend-login

if [ "$S3QL_USER" ]; then
    sed -i "s/^backend-login:.*/backend-login: $S3QL_USER/" $CONFIGFILE
fi

# backend-password

if [ "$S3QL_PASSWORD" ]; then
    sed -i "s/^backend-password:.*/backend-password: $S3QL_PASSWORD/" $CONFIGFILE
fi

# filesystem passphrase

if [ "$S3QL_FSPP" ]; then
    sed -i "s/^fs-passphrase:.*/fs-passphrase: $S3QL_FSPP/" $CONFIGFILE
fi

echo starting s3ql on $S3QL_STORAGE_URL ...

# FSCK on startup just in case
echo "starting fsck ..."
echo " /usr/local/bin/fsck.s3ql swift://$S3QL_STORAGE_URL $BACKEND_OPTIONS"
echo "continue"| /usr/local/bin/fsck.s3ql swift://$S3QL_STORAGE_URL $BACKEND_OPTIONS

# MOUNT S3QL filesystem
echo "starting mount ..."
/usr/local/bin/mount.s3ql --threads 10 --compress none --nfs \
  --cachedir /tmp \
  --log none \
  --cachesize $S3QL_CACHESIZE \
  --max-cache-entries $S3QL_CACHE_ENTRIES \
  --allow-other --metadata-upload-interval $S3QL_METADATA_INTERVAL \
  --backend-options no-ssl \
  swift://$S3QL_STORAGE_URL \
  --fg \
  $S3QL_MOUNT &

# Capture SIGTERM to umount filesystem
trap "echo umounting... ; /usr/local/bin/umount.s3ql $S3QL_MOUNT; exit 0" SIGTERM
while true; do :; done
