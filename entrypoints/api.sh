#!/bin/sh

DCI_LOGIN='admin' DCI_PASSWORD='admin' python /opt/dci-control-server/bin/dci-dbinit

if [[ -n "$DUMP_FILE" ]]; then
    . /opt/rh/rh-postgresql94/enable
    PGPASSWORD='dci' pg_restore -U dci -c -d dci -h db -1 /tmp/database-dumps/$DUMP_FILE
fi

python /opt/keycloak-provision.py

pubkey=$(python bin/dci-get-pem-ks-key.py http://keycloak:8180 dci-test)

export SSO_PUBLIC_KEY="$pubkey"

exec "$@"
