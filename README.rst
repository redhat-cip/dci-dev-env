Distributed CI environment for development
==========================================

This repository is used to store the configuration of docker
compose in order to provide an environment for development.

Getting started
---------------

For running dci in docker compose follow those steps:

* clone this repository
* clone all the dci related project into this repository:

  * http://softwarefactory-project.io/r/dci-control-server
  * http://softwarefactory-project.io/r/python-dciclient
  * http://softwarefactory-project.io/r/dci-ui
  * http://softwarefactory-project.io/r/dci-doc

* install docker-compose and git-review if you want to contribute,
  the correct versions are described in `requirements.txt <requirements.txt>`_
  you can install those requirements by simply typing:
  ``pip install -r requirements.txt``
* you have two way to launch the environment, the automated and the manual
  * for the automated just launch ``docker-compose -f dci.yml -f dci-db_init.yml up``
    And after the first boot of the env you can stay
    with ``docker-compose -f dci.yml up`` to keep your database
  * to get the manual way use : ``docker-compose -f dci.yml -f dci-manual.yml up``
    it will let you attach the api and the webapp

Now the environment is up and running, you can attach containers in order to
run parts of the applications. For further information see
`the containers section <#containers>`_.

Containers
----------

There is five container for running the application

* **dci_db**: contains the postgresql database, it is started by default and
  serve the database on localhost port 5432.
* **dci_es**: contains the elasticsearch database, it is started by default and
  serve on localhost port 9200 and 9300.
* **dci_influxdb**: contains the influxdb time series database, it is started
  by default and serve on localhost port 8083 and 8086.
* **dci_grafana**: contains the grafana dashboard server, it is started by
  default and serve on localhost port 3000.
* **dci_api**: contains the api of the application, it must be started manually
  (see `the following section for details <#api-container>`_). The API is
  served on localhost port 5000.
* **dci_app**: contains the web app of dci, it must be started manually
  (see `the following section for details <#app-container>`_). The web
  application is served on localhost port 8000.
* **dci_tox**: contains all the needed module for testing, it is not needed
  for running the application but is a helper in order to run tests
  on the client and the API
  (see `the following section for details <#tox-container>`_).
* **dci_doc**: helper for building the documentation of the project
  (see `the following section for details <#doc-container>`_).
* **dci_dbwatcher**: helper for interacting with the database.
  (see `the following section for details <#dbwatcher-container>`_).
* **dci_client**: contains the python-dciclient.
  (see `the following section for details <#client-container>`_).

API container
~~~~~~~~~~~~~

In the following section we will assume that we run the commands in the
dedicated container, just after attaching it with
``docker attach <container-name>``

To initialize this container you need to perform some operations:

* initialize or reinitialize the database by running
  `./scripts/db_provisioning.py <https://github.com/redhat-cip/dci-control-server/blob/master/scripts/db_provisioning.py>`_
* start the development server by running
  `./script/runtestserver.py <https://github.com/redhat-cip/dci-control-server/blob/master/scripts/db_provisioning.py>`_

APP container
~~~~~~~~~~~~~

In the following section we will assume that we run the commands in the
dedicated container, just after attaching it with
``docker attach <container-name>``

Like the api you need to perform some operations before running the app:

* install npm dependencies for the application: ``npm install``
* run the application: `gulp serve:dev`

This container also contains some targets for testing the frontend, see the
`gulpfile <https://github.com/redhat-cip/dci-ui/blob/master/gulpfile.js>`_
for more informations.

TOX container
~~~~~~~~~~~~~

In the following section we will assume that we run the commands in the
dedicated container, just after attaching it with
``docker attach <container-name>``

This container is a helper for launching tests on the client and/or the api,
just navigate to the correct project directory and run the tox command in order
to launch the tests.

DOC container
~~~~~~~~~~~~~

This container is particular because it is not started by default.
It only provides an entrypoint for the sphinx documentation generation.

To run it and see the default commands type:
``docker-compose -f dci.yml run doc``

To generate an html output of the doc for a preview type:
``docker-compose -f dci.yml run doc html``

DBwatcher container
~~~~~~~~~~~~~~~~~~~

This container is ran, generates a schema of the db in png format,
then stopped. You will have to run it again and attach it in order to interact
with the database.

To run and attach the container type:
``docker-compose -f dci.yml run dbwatcher bash``

Then you can run ``psql`` it will directly attach to the dci_control_server
database.

If you want to generate the database schema again just run the container
without overriding the entrypoint:
``docker-compose -f dci.yml run dbwatcher``

CLIENT container
~~~~~~~~~~~~~~~~

This container allows one to run the python-dciclient within it.

This container is special in several ways compares to the others:

  * It runs CentOS 7 and not Fedora 23
  * It runs systemd
  * It runs an sshd daemon (root/root)

In the following section we will assume that we run the commands in the
dedicated container, just after attaching it with
``docker attach <container-name>``

To initialize this container you need to perform some operations:

* Install the dciclient library, as well as the agents and feeders:
 ``cd /opt/python-dciclient && pip install -e .``
 ``cd /opt/python-dciclient/agents && pip install -e .``
 ``cd /opt/python-dciclient/feeders && pip install -e .``

* Create a local.sh file with the following credentials and source it:

.. code:: bash

  export DCI_LOGIN=admin
  export DCI_PASSWORD=admin
  export DCI_CS_URL=http://$API_CONTAINER_IP:5000

Note: The $API_CONTAINER_IP can be optained by running ``docker inspect --format '{{ .NetworkSettings.IPAddress }}' <container-id>``
