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

    podman-compose exec <container-name> bash

For instance

    podman-compose exec api bash

To see logs of a specific container, use podman logs command

    podman-compose logs -f api

## Containers

Here is the list of containers for running the application:

- `db`: contains the postgresql database and serves it on localhost port `5432`, started by default ;
- `api`: contains the API of the application and serves it on localhost port `5000` ;
- `tox`: container used to run test on dci-control-server, python-dciclient and dci-ansible ;

Other services are available in dci-`<service>`.yml

- `ui`: contains the web app of DCI and serves it on localhost port `8000`.
- `doc`: helper to build the project's documentation ;
- `keycloak`: keycloak server for `SSO`. :warning: Use `localhost` as `keycloak`'s domain as it's set to this value and not <s>`127.0.0.1`</s> ;
- `analytics`: analytics container running elatic service.
- `feeder`: feeder container for synchronizing components.

### API Container

You can initialize or re-initialize the database from the API container by running:

    podman-compose exec api ./bin/dci-dbprovisioning

### Tox Container

This container allows to run test on dci-control-server, python-dciclient and dci-ansible.

To run `tox` on dci-control-server:

    podman-compose exec -w /opt/dci-control-server tox tox

To run `tox` on python-dciclient:

    podman-compose exec -w /opt/python-dciclient tox tox

To run `tox` on dci-ansible:

    podman-compose exec -w /opt/dci-ansible tox tox

### Keycloak Container

This container allows to use `SSO` based authentication.
See dci-keycloak/README.md

### Documentation Container

This container generates DCI documentation.

Use the following command to generate the doc:

    podman-compose -f dci-doc.yml run doc

### Contribute

You will need to install `podman-compose` and `git-review`:

    pip install -U -r requirements.txt
