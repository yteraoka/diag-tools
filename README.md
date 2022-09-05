# diag-tools

- https://github.com/yteraoka/diag-tools/pkgs/container/diag-tools
  - `docker pull ghcr.io/yteraoka/diag-tools:latest`
- https://hub.docker.com/repository/docker/yteraoka/diag-tools/general
  - `docker pull yteraoka/diag-tools:latest`

## Install されているもの

- curl
- ping
- ip
- dig, host
- tcpdump
- lsof
- strace
- openssl
- jq
- gcloud
- kubectl
- MySQL/MariaDB Client (mariadb-client)
- PostgreSQL Client (psql)

## 調査用 Pod の作成

```yaml
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: debug
spec:
  containers:
    - name: debian
      image: ghcr.io/yteraoka/diag-tools:0.3.0
      command:
        - /bin/bash
      args:
        - -c
        - sleep infinity
EOF
```

```yaml
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: debug
  #labels:
  #  use-fargate: "true"
spec:
  serviceAccountName: xxx
  containers:
    - name: debian
      image: ghcr.io/yteraoka/diag-tools:0.3.0
      command:
        - /bin/bash
      args:
        - -c
        - sleep infinity
      resources:
        limits:
          cpu: 500m
          memory: 512Mi
        requests:
          cpu: 500m
          memory: 512Mi
EOF
```
