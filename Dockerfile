FROM alpine:3.18.2 as downloader

WORKDIR /download

# renovate: datasource=github-releases depName=ComunidadAylas/PackSquash
ARG PACKSQUASH_VERSION=v0.4.0

RUN apk add wget unzip && \
    wget -O archive.zip "https://github.com/ComunidadAylas/PackSquash/releases/download/${PACKSQUASH_VERSION}/PackSquash.CLI.executable.$([[ "$(uname -m)" == "x86_64" ]] && echo "x86_64" || echo "aarch64")-unknown-linux-musl.zip" && \
    unzip archive.zip && \
    chmod +x packsquash

FROM debian:buster-slim

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