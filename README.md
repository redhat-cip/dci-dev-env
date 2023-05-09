# Distributed CI environment for development

This repository is used to store the configuration of podman compose in order to provide an environment for development.

## Installation

To run DCI in `podman-compose`, first clone this repository:

    git clone git@github.com:redhat-cip/dci-dev-env.git

Then, bootstrap `dci-dev-env`:

    ./utils/bootstrap.sh

## Usage

Once install, you can launch the environment:

    podman-compose up -d

Then, you can attach containers in order to run parts of the applications:

    podman exec -it <container-name> bash

For instance

    podman exec -it api bash

To see logs of a specific container, use podman logs command

    podman-compose logs -f api

## Containers

Here is the list of containers for running the application:

- `db`: contains the postgresql database and serves it on localhost port `5432`, started by default ;
- `api`: contains the API of the application and serves it on localhost port `5000`, **must be started manually** ;
- `client`: contains the `dciclient` (Python binding) and `dcictl` (CLI) clients to DCI Control Server ;

Other services are available in dci-`<service>`.yml

- `ui`: contains the web app of DCI and serves it on localhost port `8000`.
- `ansible`: contains the dci-ansible code ;
- `doc`: helper to build the project's documentation ;
- `keycloak`: keycloak server for `SSO`. :warning: Use `localhost` as `keycloak`'s domain as it's set to this value and not <s>`127.0.0.1`</s> ;
- `analytics`: storage backend for the API using a Swift server.

- `swift`: storage backend for the API using a Swift server.

### API Container

You can initialize or re-initialize the database from the API container by running:

    podman exec -it api ./bin/dci-dbprovisioning

### Client Container

This container allows to run `python-dciclient`.

This container is special in several ways compares to the others:

- It runs `systemd` ;
- It runs an `sshd` daemon that belong to `root:root`.

#### Client Usage

To initialize this container you need to install the `dciclient` library, as well as the agents and feeders:

    cd /opt/python-dciclient && pip install --editable ./
    cd /opt/python-dciclient/agents && pip install --editable ./
    cd /opt/python-dciclient/feeders && pip install --editable ./

Then, Create a _local.sh_ file with the following credentials and source it:

    API_CONTAINER_IP="$(docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <CONTAINER_ID>)"
    export DCI_LOGIN=admin
    export DCI_PASSWORD=admin
    export DCI_CS_URL=http://$API_CONTAINER_IP:5000

### Keycloak Container

This container allows to use `SSO` based authentication.
See dci-keycloak/README.md

### Ansible Container

You can use the Ansible container to run `tox`:

    podman exec -it ansible tox

and the functional tests:

    podman exec -it ansible bash -c 'cd tests; ./run_tests.sh'

### Swift Container

If you want to enable the `swift` storage for the API:

    ln -s dci-swift.yml podman-compose.override.yml
    podman-compose build
    podman-compose up -d

`Swift` is exposed on the **non-standard port `5001`**. If you want to interact with it, you can use
your local `swift` client.

    source dci-swift/openrc_dci.sh
    swift upload fstab /etc/fstab
    swift list

### Documentation Container

This container generates DCI documentation.

Use the following command to generate the doc:

    podman-compose -f dci-doc.yml run doc

### Contribute

You will need to install `podman-compose` and `git-review`:

    pip install -U -r requirements.txt
