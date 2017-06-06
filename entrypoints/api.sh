#!/bin/sh

python /opt/dci-control-server/scripts/db_provisioning.py -ym

exec "$@"
