ARG BASE_IMAGE=debian:stable-slim

FROM $BASE_IMAGE

LABEL base_image=$BASE_IMAGE

ARG TINI_STATIC_URL="https://github.com/krallin/tini/releases/download/v0.18.0/tini-static"
ARG DOCKER_STATIC_TGZ="https://download.docker.com/linux/static/stable/x86_64/docker-19.03.4.tgz"

RUN  \
  DEBIAN_FRONTEND=noninteractive \
  apt-get -y update \
  && apt-get -y install bsdtar curl ca-certificates procps \
  && curl -sSfL -o /usr/local/bin/tini "${TINI_STATIC_URL}" \
  && chmod 755 /usr/local/bin/tini \
  && curl -sSfL "${DOCKER_STATIC_TGZ}" \
  | bsdtar -xzv -C /usr/local/bin --strip-components 1 -f -  docker/docker \
  && chmod 755 /usr/local/bin/docker

COPY check-inodes.sh /opt/

CMD ["/usr/local/bin/tini","-g","--","sh","/opt/check-inodes.sh"]
