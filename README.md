# Distributed CI environment for development

This repository is used to store the configuration of docker
compose in order to provide an environment for development.

## Getting started

For running dci in docker compose follow those steps:

- clone this repository:

      git@github.com:redhat-cip/dci-dev-env.git

- bootstrap dci-dev-env, run

      ./utils/bootstrap.sh

- install `docker-compose` and `git-review` if you want to contribute,
  you can install those requirements by simply typing:

      pip install -U -r requirements.txt

## Usage

Once install, you can launch the environment:

    docker-compose -f dci.yml up -d

Then, you can attach containers in order to run parts of the applications:

    docker exec -it <container-name> bash

For instance `docker exec -it dci-dev-env_api_1 bash`

## Containers

Here is the list of containers for running the application:

* `dci_ansible`: contains the dci-ansible code ;
* `dci_api`: contains the API of the application and serves it on localhost port `5000`, **must be started manually** ;
* `dci_client`: contains the `dciclient` (Python binding) and `dcictl` (CLI) clients to DCI Control Server ;
* `dci_db`: contains the postgresql database and serves it on localhost port `5432`, started by default ;
* `dci_doc`: helper to build the project's documentation ;
* `dci_keycloak`: keycloak server for `SSO`. :warning: Use `localhost` as `keycloak`'s domain as it's set to this value and not <s>`127.0.0.1`</s> ;
* `dci_ui`: contains the web app of DCI and serves it on localhost port `8000`.
* `dci_swift`: storage backend for the API using a Swift server.

### API Container

You can initialize or re-initialize the database from the API container by running:

    docker exec -it dci-dev-env_api_1 ./bin/dci-dbprovisioning

### Client Container

> This container allows one to run the `python-dciclient` within it.
> 
> This container is special in several ways compares to the others:
> 
> - It runs `systemd` ;
> - It runs an `sshd` daemon that belong to `root:root`.

To initialize this container you need to perform some operations:

1. Install the `dciclient` library, as well as the agents and feeders:

        cd /opt/python-dciclient && pip install --editable ./
        cd /opt/python-dciclient/agents && pip install --editable ./
        cd /opt/python-dciclient/feeders && pip install --editable ./

2. Create a _local.sh_ file with the following credentials and source it:

        API_CONTAINER_IP="$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' <CONTAINER_ID>)"
        export DCI_LOGIN=admin
        export DCI_PASSWORD=admin
        export DCI_CS_URL=http://$API_CONTAINER_IP:5000

### Keycloak Container

> This container allows to use `SSO` based authentication.


#### Provisioning

It's provisioned by default by the following:

- The user admin: `username=admin`, `password=admin` ;
- A realm `dci-test` ;
- A client `dci-cs` ;
- A lambda user within the `dci-test` realm: `username=dci`, `password=dci`

The client `dci-cs` is configured to allows _OIDC Implicit flow_ and _Direct Access_ protocols.

#### Use OIDC Implicit flow

Generate a random value using an `UUID`, then we will use it for the `nonce` field in the following link:

    http://localhost:8180/auth/realms/dci-test/protocol/openid-connect/auth?\
    client_id=dci-cs&\
    response_type=id_token&\
    scope=openid&\
    nonce=YOU_MUST_REPLACE_ME&\
    redirect_uri=http://localhost:5000/rh-partner

This link will redirect the browser to Keycloak `SSO` login page, once authenticated it will redirect to the `redirect_uri` value. _e.g._:

**:warning: fixme: is it a URI or URI+payload?**

    http://localhost:5000/rh-partner#\
    id_token=eyJhs ... EPscxhRMuEdA&\
    not-before-policy=0

The `id_token` parameter correspond to the _JSON Web Token_ (`jwt`) generated by Keycloak and will be used to authenticated the client on the server.

#### Use Direct Access protocol

From the CLI:

    $ curl \
      --data "client_id=dci-cs" \
      --data "username=dci" \
      --data "password=dci" \
      --data "grant_type=password" \
      http://localhost:8180/auth/realms/dci-test/protocol/openid-connect/token

This will get a `JWT` and will be used to authenticated the client on the server .

### Ansible Container

You can use the Ansible container to run `tox`:

    docker exec -it dci-dev-env_ansible_1 tox

and the functional tests:

    docker exec -it dci-dev-env_ansible_1 bash -c 'cd tests; ./run_tests.sh'

### Swift Container

If you want to enable the `swift` storage for the API:

    docker-compose -f dci.yml -f dci-swift.yml build
    docker-compose -f dci.yml -f dci-swift.yml up -d

`Swift` is exposed on the **non-standard port `5001`**. If you want to interact with it, you can use
your local `swift` client.

    source dci-swift/openrc_dci.sh
    swift upload fstab /etc/fstab
    swift list

### Documentation Container

> This container generates DCI documentation.

Use the following command to generate the doc:

    docker-compose -f dci.yml -f dci-extra.yml run doc
