#!/bin/sh

sed -i 's#git+http://softwarefactory-project.io/r/dci-control-server#-e /opt/dci#g' /opt/dci-client/test-requirements.txt

exec "$@"
