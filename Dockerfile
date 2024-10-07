ARG ALPINE_VERSION=3.20.3
FROM alpine:${ALPINE_VERSION} AS build
ARG ALPINE_VERSION
WORKDIR /src
COPY ./src /src

RUN apk --no-cache add \
    curl \
    cpio \
    findutils

ENV ALPINE_VERSION=${ALPINE_VERSION}
RUN ./alpine-build-root.sh

FROM scratch
#COPY --from=build /src/kernel /
COPY --from=build /src/initramfs /
