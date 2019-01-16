#!/bin/sh
DCI_GIT_REPO_DIR="/home/tvass/Documents/work/dci/dci-dev-env" 
cd ${DCI_GIT_REPO_DIR}


# Build
buildah bud -tag dci-control-server ${DCI_GIT_REPO_DIR}/dci-control-server/
buildah bud -tag dci-ui ${DCI_GIT_REPO_DIR}/dci-ui/
buildah pull jboss/keycloak
buildah pull centos/postgresql-94-centos7

# Podman does NOT support VOLUME cmd in Dockerfile (see https://github.com/containers/libpod/issues/2170)
podman volume create node_modules
podman run -ti --rm --network=host -v ${DCI_GIT_REPO_DIR}/dci-ui:/opt/dci-ui:Z -v node_modules:/opt/dci-ui/node_modules localhost/dci-ui npm install

# Run

#podman run --rm --network=host --env KEYCLOACK_USER=admin --env KEYCLOACK_PASSWORD=admin jboss/keycloak
#podman run --rm --network=host --env POSTGRESQL_USER=dci --env POSTGRESQL_PASSWORD=dci --env POSTGRESQL_DATABASE=dci -v ${DCI_GIT_REPO_DIR}/dci-db:/opt/app-root/src centos/postgresql-94-centos7
#podman run --rm --network=host -v ${DCI_GIT_REPO_DIR}/dci-ui:/opt/dci-ui:Z -v node_modules:/opt/dci-ui/node_modules localhost/dci-ui
#podman run --rm --network=host -p 8180:8080 --env DEBUG=1 --env API_HOST=api --env DB_HOST=db --env STORE_ENGINE=file -v ${DCI_GIT_REPO_DIR}/dci-control-server:/opt/dci-control-server:Z localhost/dci-control-server

