#!/bin/bash

CURL=$(which curl 2> /dev/null)
NC=$(which nc 2> /dev/null)
NC_OPTS="-z"

vault() {
  docker exec -it vault vault "$@"
}

inspect() {

  echo "inspect needed containers"
  for d in consul-master consul2 vault
  do
    # docker inspect --format "{{lower .Name}}" ${d}
    docker inspect --format '{{with .State}} {{$.Name}} has pid {{.Pid}} {{end}}' ${d}
  done
}

api_request_consul() {

  node=$1

  code=$(curl \
    --silent \
    http://localhost:8500/v1/health/node/${node})

  if [[ $? -eq 0 ]]
  then
    echo "api request for consul $1 are successfull"
    echo ""
  else
    echo ${code}
    echo "api request failed"
    exit 1
  fi
}

api_request_vault() {

  code=$(curl \
    --silent \
    http://127.0.0.1:8200/v1/sys/health)

  if [[ $? -eq 0 ]]
  then
    echo "api request for vault are successfull"
    echo ""
  else
    echo ${code}
    echo "api request failed"
    exit 1
  fi
}

unseal() {

  VAULT_ADDR="http://localhost:8200"

  echo "vault init .."
  vault operator init -address=${VAULT_ADDR} -format=json > keys.txt

  key_1=$(cat keys.txt | jq --raw-output .unseal_keys_b64[0])
  key_2=$(cat keys.txt | jq --raw-output .unseal_keys_b64[1])
  key_3=$(cat keys.txt | jq --raw-output .unseal_keys_b64[2])

  echo ""
  echo "vault unseal .."
  vault operator unseal -address=${VAULT_ADDR} ${key_1}
  echo ""
  vault operator unseal -address=${VAULT_ADDR} ${key_2}
  echo ""
  vault operator unseal -address=${VAULT_ADDR} ${key_3}
  echo ""
  echo "vault status .."
  vault status -address=${VAULT_ADDR}
  echo ""

}

inspect

api_request_consul consul-master
api_request_consul consul2
unseal
api_request_vault

exit 0
