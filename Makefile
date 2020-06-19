include podman-env

build:
	podman build -t dci-dev-env_api $(CURDIR)/dci-control-server

build-ui:
	podman build -t dci-dev-env_ui $(CURDIR)/dci-ui

build-client:
	podman build -t dci-dev-env_client $(CURDIR)/python-dciclient

build-ansible:
	podman build -t dci-dev-env_ansible $(CURDIR)/dci-ansible

pull:
	podman pull centos/postgresql-96-centos7
	podman pull jboss/keycloak

down:
	podman pod rm -f dci-dev-env

logs-db:
	podman logs db

logs-api:
	podman logs api

logs-ui:
	podman logs ui	

ps:
	podman ps

ps-all:
	podman ps -pa

prune:
	podman volume rm -f pgdata

up:
	podman pod create --name dci-dev-env -p 5000:5000 -p 8000:8000
	podman run --name keycloak --pod dci-dev-env -dt \
		-v $(CURDIR):/code \
		-e KEYCLOAK_USER=$(KEYCLOAK_USER) -e KEYCLOAK_PASSWORD=$(KEYCLOAK_PASSWORD) \
		jboss/keycloak
	podman run --name db --pod dci-dev-env -dt \
		-v $(CURDIR)/dci-db:/opt/app-root/src:Z \
		-e POSTGRESQL_USER=$(POSTGRESQL_USER) \
		-e POSTGRESQL_PASSWORD=$(POSTGRESQL_PASSWORD) \
		-e POSTGRESQL_DATABASE=$(POSTGRESQL_DATABASE) \
		centos/postgresql-96-centos7
	podman run --name api --pod dci-dev-env -dt \
		-v $(CURDIR)/dci-control-server:/opt/dci-control-server:Z \
		-e API_HOST=$(API_HOST) -e DB_HOST=$(DB_HOST) -e STORE_ENGINE=$(STORE_ENGINE) \
		-e KEYCLOAK_HOST=$(KEYCLOAK_HOST) -e KEYCLOAK_PORT=$(KEYCLOAK_PORT) \
		dci-dev-env_api

up-ui:
	podman run --name ui --pod dci-dev-env -dt \
		-v $(CURDIR)/dci-ui:/opt/dci-ui:Z \
		dci-dev-env_ui
	
up-client:
	podman run --name client --pod dci-dev-env -dt \
		-v $(CURDIR)/python-dciclient:/opt/python-dciclient:Z \
		-v $(CURDIR)/dci-control-server:/opt/dci-control-server:Z \
		-e API_HOST=$(API_HOST) -e DB_HOST=$(DB_HOST) -e STORE_ENGINE=$(STORE_ENGINE) \
		dci-dev-env_client

up-ansible:
	podman run --name ansible --pod dci-dev-env -dt \
		-v $(CURDIR)/python-dciclient:/opt/python-dciclient:Z \
		-v $(CURDIR)/dci-ansible:/opt/dci-ansible:Z \
		-e DCI_LOGIN=$(DCI_LOGIN) -e DCI_PASSWORD=$(DCI_PASSWORD) -e DCI_CS_URL=$(DCI_CS_URL) \
		-e DB_HOST=$(DB_HOST) \
		dci-dev-env_ansible
	
shell:
	podman exec -it client bash

start:
	podman pod start dci-dev-env

stop:
	podman pod stop dci-dev-env
