
FROM alpine:3.6

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

ENV \
  ALPINE_MIRROR="mirror1.hs-esslingen.de/pub/Mirrors" \
  ALPINE_VERSION="v3.6" \
  TERM=xterm \
  BUILD_DATE="2017-10-12" \
  VAULT_VERSION="0.8.3" \
  VAULT_URL="https://releases.hashicorp.com/vault" \
  APK_ADD="ca-certificates curl unzip"

EXPOSE 8200

LABEL \
  version="1709-37" \
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
  echo "http://${ALPINE_MIRROR}/alpine/${ALPINE_VERSION}/main"       > /etc/apk/repositories && \
  echo "http://${ALPINE_MIRROR}/alpine/${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
  apk --no-cache update && \
  apk --no-cache upgrade && \
  apk --no-cache add ${APK_ADD} && \
  curl \
    --silent \
    --location \
    --retry 3 \
    --cacert /etc/ssl/certs/ca-certificates.crt \
    --output /tmp/vault_${VAULT_VERSION}_linux_amd64.zip \
    "${VAULT_URL}/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip" && \
  unzip /tmp/vault_${VAULT_VERSION}_linux_amd64.zip -d /usr/bin/ && \
  apk --purge del ${APK_ADD} && \
  rm -rf \
    /tmp/* \
    /var/cache/apk/*

ENTRYPOINT [ "/usr/bin/vault" ]

CMD [ "version" ]

# ---------------------------------------------------------------------------------------
