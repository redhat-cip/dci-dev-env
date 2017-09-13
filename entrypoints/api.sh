#!/bin/sh

DCI_LOGIN='admin' DCI_PASSWORD='admin' python /opt/dci-control-server/bin/dci-dbinit

python /opt/keycloak-provision.py

exec "$@"
