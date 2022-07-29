FROM debian:latest

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl iproute2 iputils-ping bind9-host dnsutils \
     tcpdump lsof strace mariadb-client postgresql-client iperf3 openssl \
     apt-transport-https ca-certificates gnupg \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN curl -Lo /usr/bin/cloud_sql_proxy https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 && chmod +x /usr/bin/cloud_sql_proxy
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" >> /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl --output - https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update && apt-get install -y google-cloud-sdk && apt-get clean && rm -fr /var/lib/apt/lists/*
