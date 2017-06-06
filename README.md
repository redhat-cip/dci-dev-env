# Distributed CI environment for development

This repository is used to store the configuration of docker
compose in order to provide an environment for development.

## Getting started

For running dci in docker compose follow those steps:

 * clone this repository
 * bootstrap dci-dev-env, run `./utils/boostrap.sh`
 * install docker-compose and git-review if you want to contribute, 
   you can install those requirements by simply typing: 
   `pip install -U -r requirements.txt`
 * launch the environment `docker-compose -f dci.yml up -d`

Now the environment is up and running, you can attach containers in order to
run parts of the applications:

    docker exec -it <container-name> bash

e.g.

    docker exec -it dcidevenv_api_1 bash

## Containers

Here is the list of containers for running the application:

 * **dci_db**: contains the postgresql database, it is started by default and
   serve the database on localhost port 5432.
 * **dci_es**: contains the elasticsearch database, it is started by default and
   serve on localhost port 9200 and 9300.
 * **dci_api**: contains the api of the application, it must be started manually
   The API is served on localhost port 5000.
 * **dci_app**: contains the web app of dci, it must be started manually
   The web application is served on localhost port 8000.
 * **dci_tox**: contains all the needed module for testing, it is not needed
   for running the application but is a helper in order to run tests
   on the client and the API.
 * **dci_doc**: helper for building the documentation of the project.
 * **dci_dbwatcher**: helper for interacting with the database.
 * **dci_client**: contains the python-dciclient.


### API container

You can initialize or reinitialize the database by running db_provisioning script:

    docker exec -it dcidevenv_api_1 bash
    ./scripts/db_provisioning.py

### TOX container

This container is a helper for launching tests on the client and/or the api, 
just navigate to the correct project directory and run the tox command in order to launch the tests.

    docker exec -it dcidevenv_tox_1 bash
    cd dci
    tox

### CLIENT container

This container allows one to run the python-dciclient within it.

This container is special in several ways compares to the others:

 * It runs systemd
 * It runs an sshd daemon (root/root)

To initialize this container you need to perform some operations:

 * Install the dciclient library, as well as the agents and feeders:

    cd /opt/python-dciclient && pip install -e .
    cd /opt/python-dciclient/agents && pip install -e .
    cd /opt/python-dciclient/feeders && pip install -e .


 * Create a local.sh file with the following credentials and source it:

```shell
export DCI_LOGIN=admin
export DCI_PASSWORD=admin
export DCI_CS_URL=http://$API_CONTAINER_IP:5000
```

Note: The $API_CONTAINER_IP can be obtained by running 

    docker inspect --format '{{ .NetworkSettings.IPAddress }}' <container-id>

## Extra containers

### Doc container

This container generates dci documentation.
If you want to generate the dci documentation run the container:

    docker-compose -f dci.yml -f dci-extra.yml run doc

### DBwatcher container

This container generates a schema of the db.
If you want to generate the database schema run the container:

    docker-compose -f dci.yml -f dci-extra.yml run dbwatcher
