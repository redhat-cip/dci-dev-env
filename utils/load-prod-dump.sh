#!/bin/bash

LOCAL_FILE=$1

if [ ! -z "${LOCAL_FILE}" ] && [ ! -f ${LOCAL_FILE} ]; then
    echo "$1 does not exist"
    exit 1
fi

if ! grep -q '127.0.0.1:\*:dci:dci:dci' ~/.pgpass; then
    echo 'Please do: echo "127.0.0.1:*:dci:dci:dci" >> ~/.pgpass; chmod 600 ~/.pgpass'
    exit 1
fi

if ! test -x $(type -p pg_restore); then
    echo 'Please install the postgresql package to get the pg_restore command.'
    exit 1
fi

if [ ! -z "${LOCAL_FILE}" ]; then
    echo "Using local backup file ${LOCAL_FILE}"
    backup_file=${LOCAL_FILE}
else
    if ! test -x $(type -p swift); then
        echo 'Please install the swift client.'
        exit 1
    fi

    if ! swift stat backup|grep -q text/plain; then
        echo 'Please ensure swift can access the backup storage.'
        exit 1
    fi

    echo 'Downloading the last backup'
    current_backup=$(swift list backup -p current/current_|tail -n1)
    backup_file=/tmp/dci-$(basename ${current_backup}).dump
    if [ -f ${backup_file} ]; then
	    echo "A backup already exists ${backup_file}. Skipping the download."
    else
        echo "Downloading backup ${current_backup} in ${backup_file}."
        swift download -o ${backup_file} backup ${current_backup}
    fi
fi

docker exec -it dcidevenv_db_1 bash -c 'echo "fsync = off" >> /var/lib/pgsql/data/userdata/postgresql.conf'
docker restart dcidevenv_db_1
sleep 5
echo 'Restoring the DB'
pg_restore --clean -h 127.0.0.1 -U dci -d dci ${backup_file}
