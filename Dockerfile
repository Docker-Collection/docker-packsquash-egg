FROM alpine:3.18.2@sha256:82d1e9d7ed48a7523bdebc18cf6290bdb97b82302a8a9c27d4fe885949ea94d1 as downloader

WORKDIR /download

# renovate: datasource=github-releases depName=ComunidadAylas/PackSquash
ARG PACKSQUASH_VERSION=v0.4.0

RUN apk add wget unzip && \
    wget -O archive.zip "https://github.com/ComunidadAylas/PackSquash/releases/download/${PACKSQUASH_VERSION}/PackSquash.CLI.executable.$([[ "$(uname -m)" == "x86_64" ]] && echo "x86_64" || echo "aarch64")-unknown-linux-musl.zip" && \
    unzip archive.zip && \
    chmod +x packsquash

FROM debian:buster-slim@sha256:cddb688e1263b9752275b064171ef6ac9c70ae21a77c774339aecfb53690b9a1

RUN apt update && apt upgrade -y \
    && apt install -y ca-certificates tzdata locales \
    && update-locale lang=en_US.UTF-8 \
    && dpkg-reconfigure --frontend noninteractive locales \
    && useradd -m -d /home/container -s /bin/bash container

USER  container
ENV  USER=container HOME=/home/container
ENV  DEBIAN_FRONTEND noninteractive

WORKDIR  /home/container

COPY --from=downloader /download/packsquash /bin/
COPY  ./entrypoint.sh /entrypoint.sh
CMD  [ "/bin/bash", "/entrypoint.sh" ]