FROM debian:latest

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl iproute2 iputils-ping bind9-host dnsutils \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
