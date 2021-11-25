#!/bin/bash

if ! [ -x "$(command -v swift)" ]; then
    echo 'Please install the swift client.'
    echo 'python3 -m pip install python-swiftclient'
    exit 1
fi

if ! swift stat backup|grep -q Last-Modified; then
    echo 'Please ensure swift can access the backup storage.'
    echo 'python3 -m pip install python-keystoneclient'
    echo 'source <(pass openrc.sh)'
    exit 1
fi

echo 'Downloading the last backup'
BACKUP=/tmp/last$$.dump
swift download -o ${BACKUP} backup $(swift list backup --long | sort -k 2,3 | tail -n 1 | sed 's!.*application/x-sql !!')
echo "Backup file ${BACKUP} downloaded"
