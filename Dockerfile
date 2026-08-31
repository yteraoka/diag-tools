FROM debian:13.6

# pipefail を指定可能にする
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# apt-get install で prompt を表示させない
ENV DEBIAN_FRONTEND=noninteractive
ENV PAGER="less -X"
ENV LANG=C.utf-8

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends curl iproute2 iputils-ping bind9-host dnsutils \
     tcpdump lsof strace mariadb-client postgresql-client iperf3 openssl less \
     apt-transport-https ca-certificates gnupg jq vim sslscan fortune awscli \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local
RUN curl -o google-cloud-cli.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz \
 && tar xf google-cloud-cli.tar.gz \
 && ./google-cloud-sdk/install.sh --quiet \
 && rm -f google-cloud-cli.tar.gz \
 && ./google-cloud-sdk/bin/gcloud components install cloud-sql-proxy cloud-run-proxy beta docker-credential-gcr --quiet \
 && echo "source /usr/local/google-cloud-sdk/path.bash.inc" >> /etc/bash.bashrc \
 && echo "source /usr/local/google-cloud-sdk/completion.bash.inc" >> /etc/bash.bashrc

WORKDIR /

# kubectl 1.35.x
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
      cat /tmp/versions.* | sort --version-sort | grep ^v1.35 | tail -n 1) \
 && rm -f /tmp/versions.* \
 && echo "Install kubectl ${kube_version}" 1>&2 \
 && curl -sfLo /usr/bin/kubectl https://dl.k8s.io/release/${kube_version}/bin/linux/amd64/kubectl \
 && chmod +x /usr/bin/kubectl
