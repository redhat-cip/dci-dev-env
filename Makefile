include podman-env

bootstrap:
	@ ./utils/bootstrap.sh

clean:
	rm -rf dci-control-server
	rm -rf dci-ui
	rm -rf python-dciclient
	rm -rf dci-ansible
	rm -rf dci-doc

build:
	podman build -t dci-dev-env_api $(CURDIR)/dci-control-server

build-ui:
	podman build -t dci-dev-env_ui $(CURDIR)/dci-ui

build-client:
	podman build -t dci-dev-env_client $(CURDIR)/python-dciclient

build-ansible:
	podman build -t dci-dev-env_ansible $(CURDIR)/dci-ansible

build-doc:
	podman build -t dci-dev-env_doc $(CURDIR)/dci-doc

build-all: build build-ui build-client build-ansible build-doc

pull:
	podman pull centos/postgresql-96-centos7
	podman pull jboss/keycloak

logs-db:
	podman logs db

logs-api:
	podman logs api

logs-ui:
	podman logs ui	

ps:
	podman ps -pa

prune:
	podman volume rm -f pgdata

up:
	podman pod create --name dci-dev-env -p $(API_PORT):$(API_PORT) -p $(UI_PORT):$(UI_PORT) -p $(DOC_PORT):$(DOC_PORT)
	podman run --name keycloak --pod dci-dev-env -dt \
		-v $(CURDIR):/code \
		-e KEYCLOAK_USER=$(KEYCLOAK_USER) -e KEYCLOAK_PASSWORD=$(KEYCLOAK_PASSWORD) \
		--health-cmd "curl -sf http://localhost:$(KEYCLOAK_PORT)/auth" \
		--health-interval "15s" --health-retries "5" --health-start-period "30s" \
		jboss/keycloak
	podman run --name db --pod dci-dev-env -dt \
		-v $(CURDIR)/dci-db:/opt/app-root/src:Z \
		-e POSTGRESQL_USER=$(POSTGRESQL_USER) \
		-e POSTGRESQL_PASSWORD=$(POSTGRESQL_PASSWORD) \
		-e POSTGRESQL_DATABASE=$(POSTGRESQL_DATABASE) \
		--health-cmd "/bin/sh -c 'source /opt/rh/rh-postgresql96/enable && pg_isready -d $(POSTGRESQL_DATABASE) -U $(POSTGRESQL_USER) -h localhost'" \
		--health-interval "10s" --health-retries "5" --health-start-period "30s" \
		centos/postgresql-96-centos7
	podman run --name api --pod dci-dev-env -dt \
		-v $(CURDIR)/dci-control-server:/opt/dci-control-server:Z \
		-e API_HOST=$(API_HOST) -e DB_HOST=$(DB_HOST) -e STORE_ENGINE=$(STORE_ENGINE) \
		-e KEYCLOAK_HOST=$(KEYCLOAK_HOST) -e KEYCLOAK_PORT=$(KEYCLOAK_PORT) \
		--health-cmd "curl -sf http://localhost:$(API_PORT)/api/v1" \
		--health-interval "10s" --health-retries "5" --health-start-period "15s" \
		dci-dev-env_api

ui:
	podman run --rm --name ui --pod dci-dev-env -dt \
		-v $(CURDIR)/dci-ui:/opt/dci-ui:Z \
		-v /opt/dci-ui/node_modules \
		--health-cmd "curl -sf http://localhost:$(UI_PORT)/" \
		--health-interval "10s" --health-retries "5" --health-start-period "30s" \
		dci-dev-env_ui

doc:
	podman run --rm --name doc --pod dci-dev-env -dt \
		-v $(CURDIR)/dci-doc:/opt/dci-doc:Z \
		-v /opt/dci-doc/node_modules \
		--health-cmd "curl -sf http://localhost:$(DOC_PORT)/" \
		--health-interval "10s" --health-retries "5" --health-start-period "30s" \
		dci-dev-env_doc

client:
	podman run --rm --name client --pod dci-dev-env -dt \
		-v $(CURDIR)/python-dciclient:/opt/python-dciclient:Z \
		-v $(CURDIR)/dci-control-server:/opt/dci-control-server:Z \
		-e API_HOST=$(API_HOST) -e DB_HOST=$(DB_HOST) -e STORE_ENGINE=$(STORE_ENGINE) \
		dci-dev-env_client

ansible:
	podman run --rm --name ansible --pod dci-dev-env -dt \
		-v $(CURDIR)/python-dciclient:/opt/python-dciclient:Z \
		-v $(CURDIR)/dci-ansible:/opt/dci-ansible:Z \
		-e DCI_LOGIN=$(DCI_LOGIN) -e DCI_PASSWORD=$(DCI_PASSWORD) -e DCI_CS_URL=http://localhost:$(API_PORT) \
		-e DB_HOST=$(DB_HOST) \
		dci-dev-env_ansible

all: up ui client ansible doc

health:
	@which jq
	@echo "Checking pods' health, CTRL+C to interrupt"
	@while true; do for c in db keycloak api ui doc; do \
		echo -n "$$c: "; \
		podman inspect $$c | jq -r '.[].State.Healthcheck.Status'; \
	done; echo "--------------------"; sleep 5s; done

shell:
	podman exec -it client bash

start:
	podman pod start dci-dev-env

stop:
	podman pod stop dci-dev-env

down: stop
	podman pod rm -f dci-dev-env

.PHONY: bootstrap clean build build-ui build-client build-ansible build-doc build-all pull down logs-db logs-api logs-ui ps prune up ui doc client ansible all shell start stop health
