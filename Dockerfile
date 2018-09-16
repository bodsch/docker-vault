
FROM golang:1-alpine as builder

ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_TYPE
ARG VAULT_VERSION

ENV \
  TERM=xterm \
  GOPATH=/opt/go \
  GOMAXPROCS=4 \
  GOOS=linux

# ---------------------------------------------------------------------------------------

RUN \
  echo "export BUILD_DATE=${BUILD_DATE}"         > /etc/profile.d/vault.sh && \
  echo "export BUILD_TYPE=${BUILD_TYPE}"        >> /etc/profile.d/vault.sh && \
  echo "export VAULT_VERSION=${VAULT_VERSION}"  >> /etc/profile.d/vault.sh

RUN \
  apk update  --quiet && \
  apk upgrade --quiet && \
  apk add     --quiet \
    bash git make ncurses zip

RUN \
  echo "get sources ..." && \
  go get github.com/hashicorp/vault || true && \
  cd ${GOPATH}/src/github.com/hashicorp/vault && \
  if [ "${BUILD_TYPE}" == "stable" ] ; then \
    echo "switch to stable Tag v${VAULT_VERSION}" && \
    git checkout tags/v${VAULT_VERSION} 2> /dev/null ; \
  fi

RUN \
  export PATH=${GOPATH}/bin:${PATH} && \
  cd ${GOPATH}/src/github.com/hashicorp/vault && \
  make bootstrap && \
  make && \
  cp -v bin/vault /usr/bin/

CMD ["/bin/bash"]

# ---------------------------------------------------------------------------------------

FROM alpine:3.8

EXPOSE 8200

COPY --from=builder /etc/profile.d/vault.sh  /etc/profile.d/vault.sh
COPY --from=builder /usr/bin/vault           /usr/bin/vault

ENTRYPOINT [ "/usr/bin/vault" ]

CMD [ "version" ]

# ---------------------------------------------------------------------------------------

LABEL \
  version="${BUILD_VERSION}" \
  maintainer="Bodo Schulz <bodo@boone-schulz.de>" \
  org.label-schema.build-date=${BUILD_DATE} \
  org.label-schema.name="Vault Docker Image" \
  org.label-schema.description="Inofficial Vault Docker Image" \
  org.label-schema.url="https://www.vaultproject.io/" \
  org.label-schema.vcs-url="https://github.com/bodsch/docker-vault" \
  org.label-schema.vendor="Bodo Schulz" \
  org.label-schema.version=${VAULT_VERSION} \
  org.label-schema.schema-version="1.0" \
  com.microscaling.docker.dockerfile="/Dockerfile" \
  com.microscaling.license="GNU Lesser General Public License v2.1"

# ---------------------------------------------------------------------------------------
