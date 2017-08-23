#!/bin/sh

/opt/keycloak/keycloak/bin/add-user-keycloak.sh -u $ADMIN -p $PASSWORD

exec "$@"
