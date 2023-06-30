#!/bin/bash

if ! [ -x "$(command -v aws)" ]; then
    echo 'Please install the aws client.'
    echo 'python3 -m pip install awscli'
    exit 1
fi

if ! aws s3 ls dci-db-backups-prod > /dev/null 2>&1; then
    echo 'Please ensure you can access the backup storage.'
    echo 'Type `aws configure` and `aws s3 ls dci-db-backups-prod`'
    exit 1
fi

echo 'Download the lastest backup'
BACKUP="$(aws s3 ls dci-db-backups-prod --recursive | sort | tail -n 1 | awk '{print $4}')"
aws s3 cp s3://dci-db-backups-prod/$BACKUP dci-db/$BACKUP
echo "Backup file dci-db/${BACKUP} downloaded"
