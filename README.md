docker-vault
=============

Minimal Image with Hashicorp Vault (https://www.vaultproject.io)

# Status

[![Docker Pulls](https://img.shields.io/docker/pulls/bodsch/docker-vault.svg?branch)][hub]
[![Image Size](https://images.microbadger.com/badges/image/bodsch/docker-vault.svg?branch)][microbadger]
[![Build Status](https://travis-ci.org/bodsch/docker-vault.svg?branch)][travis]

[hub]: https://hub.docker.com/r/bodsch/docker-vault/
[microbadger]: https://microbadger.com/images/bodsch/docker-vault
[travis]: https://travis-ci.org/bodsch/docker-vault


# Build

Your can use the included Makefile.

To build the Container: `make build`

To remove the builded Docker Image: `make clean`

Starts the Container: `make run`

Starts the Container with Login Shell: `make shell`

Entering the Container: `make exec`

Stop (but **not kill**): `make stop`

History `make history`


# Docker Hub

You can find the Container also at  [DockerHub](https://hub.docker.com/r/bodsch/docker-vault/)


# First steps

[look, read and play](https://www.katacoda.com/courses/docker-production/vault-secrets)

```
/src/private/docker-vault $ docker-compose -f docker-compose.yml.example up --build
```

```
alias vault='docker exec -it vault vault "$@"'
export VAULT_ADDR="http://localhost:8200"
vault operator init -address=${VAULT_ADDR} -format=json > keys.txt
vault status -address=${VAULT_ADDR}

vault operator unseal -address=${VAULT_ADDR} $(jq --raw-output .unseal_keys_b64 keys.txt  | jq --raw-output .[0])
vault operator unseal -address=${VAULT_ADDR} $(jq --raw-output .unseal_keys_b64 keys.txt  | jq --raw-output .[1])
vault operator unseal -address=${VAULT_ADDR} $(jq --raw-output .unseal_keys_b64 keys.txt  | jq --raw-output .[2])

vault status -address=${VAULT_ADDR}

export VAULT_TOKEN=$(grep 'Initial Root Token:' keys.txt | awk '{print substr($NF, 1, length($NF)-1)}')
vault auth -address=${VAULT_ADDR} ${VAULT_TOKEN}

vault write -address=${VAULT_ADDR} secret/api-key value=12345678

vault read -address=${VAULT_ADDR} secret/api-key

vault read -address=${VAULT_ADDR} -field=value secret/api-key


curl -H "X-Vault-Token:$VAULT_TOKEN" -XGET http://docker:8200/v1/secret/api-key

curl -s -H  "X-Vault-Token:$VAULT_TOKEN" -XGET http://docker:8200/v1/secret/api-key | jq -r .data.value


