#!/bin/sh

python /opt/dci-control-server/scripts/db_provisioning.py -y

python /opt/keycloak-provision.py

exec "$@"
