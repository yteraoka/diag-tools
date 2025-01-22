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
- vim
- gcloud
- kubectl
- MySQL/MariaDB Client (mariadb-client)
- PostgreSQL Client (psql)

## helm install

latest

```bash
helm install diag-tools oci://ghcr.io/yteraoka/chart/diag-tools
```

StatefulSet with volumeClaimTemplates

```bash
cat > myvalues.yaml <<EOF
volumeMounts:
  - mountPath: /tmp
    name: tmp
statefulSet:
  enabled: true
  volumeClaimTemplates:
    - apiVersion: v1
      kind: PersistentVolumeClaim
      metadata:
        name: tmp
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 1Gi
        volumeMode: Filesystem
EOF

helm install diag-tools oci://ghcr.io/yteraoka/chart/diag-tools -f myvalues.yaml
```

specific version

```bash
helm install diag-tools oci://ghcr.io/yteraoka/chart/diag-tools --version 0.5.16
```

or

```bash
cd chart/diag-tools
helm install diag-tools .
```

## 調査用 Pod の作成

```yaml
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: debug
spec:
  containers:
    - name: diag-tools
      image: ghcr.io/yteraoka/diag-tools:latest
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
    - name: diag-tools
      image: ghcr.io/yteraoka/diag-tools:latest
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
