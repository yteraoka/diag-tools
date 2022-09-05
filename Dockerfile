FROM debian:11.4

# pipefail を指定可能にする
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends curl iproute2 iputils-ping bind9-host dnsutils \
     tcpdump lsof strace mariadb-client postgresql-client iperf3 openssl \
     apt-transport-https ca-certificates gnupg jq \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN echo "deb https://packages.cloud.google.com/apt cloud-sdk main" >> /etc/apt/sources.list.d/google-cloud-sdk.list \
 && curl -fsLo /etc/apt/trusted.gpg.d/cloud.google.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
 && apt-get update \
 && apt-get install -y --no-install-recommends google-cloud-sdk \
 && apt-get clean \
 && rm -fr /var/lib/apt/lists/*

RUN curl -Lo /usr/bin/cloud_sql_proxy https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 \
 && chmod +x /usr/bin/cloud_sql_proxy

# kubectl 1.22.x
RUN kube_version=$( \
      i=0; \
      while :; do \
        i=$(( $i + 1 )); \
        curl -s "https://api.github.com/repos/kubernetes/kubernetes/releases?per_page=100&page=$i" \
          | jq '.[] | select(.prerelease == false) | .tag_name' -r > /tmp/versions.$i; \
        if [ ! -s /tmp/versions.$i ] ; then \
          break; \
        fi; \
        if [ $i -gt 10 ] ; then \
          break; \
        fi; \
      done; \
      cat /tmp/versions.* | sort --version-sort | grep ^v1.22 | tail -n 1) \
 && rm -f /tmp/versions.* \
 && echo "Install kubectl ${kube_version}" 1>&2 \
 && curl -sfLo /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${kube_version}/bin/linux/amd64/kubectl \
 && chmod +x /usr/bin/kubectl
