#!/bin/bash

CURL=$(which curl 2> /dev/null)
NC=$(which nc 2> /dev/null)
NC_OPTS="-z"

vault() {
  docker exec -it vault vault "$@"
}

inspect() {

  echo ""
  echo "inspect needed containers"
  for d in $(docker ps | tail -n +2 | awk  '{print($1)}')
  do
    # docker inspect --format "{{lower .Name}}" ${d}
    c=$(docker inspect --format '{{with .State}} {{$.Name}} has pid {{.Pid}} {{end}}' ${d})
    s=$(docker inspect --format '{{json .State.Health }}' ${d} | jq --raw-output .Status)

    printf "%-40s - %s\n"  "${c}" "${s}"
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
  else
    echo ${code}
    echo -e "\napi request failed\n"
    exit 1
  fi
}

api_request_vault() {

  code=$(curl \
    --silent \
    http://127.0.0.1:8200/v1/sys/health)

  if [[ $? -eq 0 ]]
  then
    echo -e "api request for vault are successfull"
  else
    echo ${code}
    echo "api request failed"
    exit 1
  fi
}

unseal() {

  VAULT_ADDR="http://localhost:8200"

  vault operator init -address=${VAULT_ADDR} -format=json > keys.json

  if [[ $(grep -c "Vault is already initialized" keys.json) -eq 0 ]]
  then
    echo "vault init .."

    key_1=$(jq --raw-output .unseal_keys_b64[0] keys.json)
    key_2=$(jq --raw-output .unseal_keys_b64[1] keys.json)
    key_3=$(jq --raw-output .unseal_keys_b64[2] keys.json)

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
  else
    echo "Vault is already initialized"
  fi

  rm -f keys.json
}

inspect

api_request_consul consul-master
api_request_consul consul2
unseal
api_request_vault

exit 0
