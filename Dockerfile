
FROM alpine:3.7

ENV \
  TERM=xterm \
  TZ='Europe/Berlin' \
  BUILD_DATE="2018-01-18" \
  VAULT_VERSION="0.9.1" \
  VAULT_URL="https://releases.hashicorp.com/vault"

EXPOSE 8200

LABEL \
  version="1801" \
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

RUN \
  apk update --quiet --no-cache  && \
  apk upgrade --quiet --no-cache  && \
  apk add --no-cache --quiet --virtual .build-deps \
    ca-certificates curl unzip && \
  curl \
    --silent \
    --location \
    --retry 3 \
    --cacert /etc/ssl/certs/ca-certificates.crt \
    --output /tmp/vault_${VAULT_VERSION}_linux_amd64.zip \
    "${VAULT_URL}/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip" && \
  unzip /tmp/vault_${VAULT_VERSION}_linux_amd64.zip -d /usr/bin/ && \
  apk --quiet --purge del .build-deps && \
  rm -rf \
    /tmp/* \
    /var/cache/apk/*

ENTRYPOINT [ "/usr/bin/vault" ]

CMD [ "version" ]

# ---------------------------------------------------------------------------------------
