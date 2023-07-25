FROM debian:12.0

# pipefail を指定可能にする
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends curl iproute2 iputils-ping bind9-host dnsutils \
     tcpdump lsof strace mariadb-client postgresql-client iperf3 openssl \
     apt-transport-https ca-certificates gnupg jq vim sslscan \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# https://cloud.google.com/sdk/docs/install?hl=ja#deb
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
 && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - \
 && apt-get update -y \
 && apt-get install google-cloud-cli -y --no-install-recommends \
 && apt-get clean \
 && rm -fr /var/lib/apt/lists/*

RUN curl -fsLo /usr/bin/cloud_sql_proxy https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 \
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
