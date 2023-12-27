FROM alpine:latest

ARG TARGETPLATFORM
RUN apk --no-cache add curl jq && cd /tmp && curl -s -o "mosdns.zip" "https://github.com/IrineSistiana/mosdns/releases/download/v5.3.1/mosdns-linux-$TARGETPLATFORM.zip" && unzip mosdns.zip && chmod +x ./mosdns && mv mosdns /usr/bin && rm -rf /tmp/* && mkdir /app 
WORKDIR /app
COPY * /app

