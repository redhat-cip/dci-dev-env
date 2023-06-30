#!/bin/bash

BACKUP_FILE=$1

if [ -z "${BACKUP_FILE}" ] ; then
    echo "Backup file path is required"
    echo "Usage: ${0##*/} lastxx.dump"
    echo "Use download-latest-backup.sh"
    exit 1
fi

podman-compose exec db pg_isready
if [ $? -ne 0 ]; then
    echo 'You database is not working.'
    echo 'command failed: pg_isready'
    exit 1
fi

echo 'Closing all the connections to the DB'
podman-compose exec db psql --quiet -d dci -h 127.0.0.1 -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='dci' AND application_name<>'psql'"
echo 'Restoring the DB'
podman-compose exec db pg_restore --verbose --clean --if-exists --dbname=dci "${BACKUP_FILE}"
echo 'Jobs count, First job created, Last jobs created:'
podman-compose exec db psql -P pager=off -d dci \
    -c '\timing' \
    -c 'select count(created_at), min(created_at), max(created_at) from jobs' \
    -c 'select version_num from alembic_version'
