FROM debian:latest

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl iproute2 iputils-ping bind9-host dnsutils \
     tcpdump lsof strace mariadb-client postgresql-client iperf3 openssl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
