ARG TARGETPLATFORM
FROM --platform=${TARGETPLATFORM} golang:alpine as builder
ARG CGO_ENABLED=0
ARG TAG 
ARG REPOSITORY

WORKDIR /root
RUN apk add git && \
    git clone https://github.com/${REPOSITORY} mosdns \
    && cd mosdns \
    && git fetch --all --tags \
    && git checkout tags/${TAG} \
    && go build -ldflags "-s -w -X main.version=${TAG}" -trimpath -o mosdns

FROM --platform=${TARGETPLATFORM} alpine:latest
LABEL maintainer="F-TD5X <mjikop1231@gmail.com>"

COPY --from=builder /root/mosdns/mosdns /usr/bin
RUN apk --no-cache add curl jq ca-certificates \
    && mkdir /etc/mosdns
COPY ./scripts /etc/mosdns/scripts
COPY entrypoint.sh /
VOLUME /etc/mosdns
EXPOSE 53/udp 53/tcp
CMD ["/entrypoint.sh"]