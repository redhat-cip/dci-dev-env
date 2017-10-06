#!/bin/sh

DCI_LOGIN='admin' DCI_PASSWORD='admin' python /opt/dci-control-server/bin/dci-dbinit

python /opt/keycloak-provision.py

pubkey=$(python bin/dci-get-pem-ks-key.py http://keycloak:8180 dci-test)

echo -n 'SSO_PUBLIC_KEY = """' >> /tmp/settings/settings.py
echo "$pubkey" >> /tmp/settings/settings.py
echo '"""' >> /tmp/settings/settings.py

exec "$@"
