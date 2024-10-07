ARG ALPINE_VERSION=3.20.3
FROM alpine:${ALPINE_VERSION} AS build
ARG ALPINE_VERSION
WORKDIR /src

RUN apk --no-cache add \
    curl

# lmao there is probably a FAR better way of grabbing the linux kernel binary from alpine pkgs
RUN apk add --no-cache linux-lts && mv /boot/vmlinuz-lts ./kernel

RUN curl https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/x86_64/alpine-minirootfs-${ALPINE_VERSION}-x86_64.tar.gz -o alpine-rootfs.tar.gz
RUN mkdir alpine-rootfs && tar xf alpine-rootfs.tar.gz -C alpine-rootfs

COPY ./src /src

RUN ./alpine-build-root.sh

FROM scratch
COPY --from=build /src/kernel /
COPY --from=build /src/initramfs /
