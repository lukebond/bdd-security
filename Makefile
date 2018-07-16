NAME := bdd-security
PKG := github.com/controlplane/$(NAME)
REGISTRY := docker.io/controlplane

SHELL := /bin/bash
BUILD_DATE := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)

CONTAINER_NAME_LATEST := $(REGISTRY)/$(NAME):latest

.PHONY: all
.SILENT:

all: help

.PHONY: build
build: ## builds a docker image
	@echo "+ $@"
	docker build . --tag ${CONTAINER_NAME_LATEST}

define pre-run
	@echo "+ pre-run"

	docker rm --force ${NAME} 1>/dev/null 2>&1 || true
endef

.PHONY: run-nessus
run-nessus: ## runs bdd-security with just the nessus_scan test tagged
	@echo "+ $@"

	@echo ${shell pwd}

	$(pre-run)
	$(run-nessus)

define run-nessus
	docker container inspect nessus-docker > /dev/null 2>&1 || { echo 'Container "nessus-docker" not found'; exit 1; }
	docker container run \
		--network=container:nessus-docker \
		-v $$(pwd)/config.xml:/home/bdd-security/config.xml \
		--name=bdd-security \
		-e TAGS="@nessus_scan" \
		-e TAGS_SKIP="~@skip" \
		controlplane/bdd-security:latest
endef

.PHONY: stop
stop: ## stops running container
	@echo "+ $@"
	docker rm --force "${NAME}" || true

.PHONY: clean
clean: ## deletes built image and running container
	@echo "+ $@"
	docker rm --force "${NAME}" || true
	docker rmi --force "${CONTAINER_NAME_LATEST}" || true

.PHONY: help
help: ## parse jobs and descriptions from this Makefile
	@grep -E '^[ a-zA-Z0-9_-]+:([^=]|$$)' $(MAKEFILE_LIST) \
    | grep -Ev '^help\b[[:space:]]*:' \
    | sort \
    | awk 'BEGIN {FS = ":.*?##"}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

