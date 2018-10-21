
include env_make

NS       = bodsch
VERSION ?= latest

REPO     = docker-vault
NAME     = vault
INSTANCE = default

BUILD_DATE     := $(shell date +%Y-%m-%d)
BUILD_VERSION  := $(shell date +%y%m)
BUILD_TYPE     ?= stable
VAULT_VERSION  ?= 0.11.3

.PHONY: build push shell run start stop rm release


default: build

params:
	@echo ""
	@echo " VAULT_VERSION : ${VAULT_VERSION}"
	@echo " BUILD_DATE    : $(BUILD_DATE)"
	@echo ""

build: params
	docker build \
		--rm \
		--compress \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg BUILD_VERSION=$(BUILD_VERSION) \
		--build-arg BUILD_TYPE=$(BUILD_TYPE) \
		--build-arg VAULT_VERSION=${VAULT_VERSION} \
		--tag $(NS)/$(REPO):$(VAULT_VERSION) .

history:
	docker history \
		$(NS)/$(REPO):$(VAULT_VERSION)

push:
	docker push \
		$(NS)/$(REPO):$(VAULT_VERSION)

shell:
	docker run \
		--rm \
		--name $(NAME)-$(INSTANCE) \
		--interactive \
		--tty \
		--entrypoint "" \
		$(PORTS) \
		$(VOLUMES) \
		$(ENV) \
		$(NS)/$(REPO):$(VAULT_VERSION) \
		/bin/sh

run:
	docker run \
		--rm \
		--name $(NAME)-$(INSTANCE) \
		$(PORTS) \
		$(VOLUMES) \
		$(ENV) \
		$(NS)/$(REPO):$(VAULT_VERSION)

exec:
	docker exec \
		--interactive \
		--tty \
		$(NAME)-$(INSTANCE) \
		/bin/sh

start:
	docker run \
		--detach \
		--name $(NAME)-$(INSTANCE) \
		$(PORTS) \
		$(VOLUMES) \
		$(ENV) \
		$(NS)/$(REPO):$(VAULT_VERSION)

stop:
	docker stop \
		$(NAME)-$(INSTANCE)

clean:
	docker rmi -f `docker images -q ${NS}/${REPO} | uniq`

#
# List all images
#
list:
	-docker images $(NS)/$(REPO)*

release: build
	make push -e VERSION=$(VAULT_VERSION)

default: build
