# Cooltainer

Container with tools for common tasks or debugging:

- sh/bash shells
- curl
- wget
- tar
- traceroute
- openssh
- traceroute
- net-tools
- netcat
- freeradius-utils
- kubectl
- oc
- mc
- nats tools
- go:1.23

Start shell:

```
namespace=default
kubectl -n $namespace run -it cooltainer --image=ghcr.io/nkzk/cooltainer:latest /bin/sh
```

Start up pod with YAML:

```
apiVersion: v1
kind: Pod
metadata:
  name: debug
  labels:
    app: debug
  namespace: default
spec:
  securityContext:
    runAsNonRoot: true
  containers:
    - name: debug
      image: 'ghcr.io/nkzk/cooltainer:latest'
      resources:
        requests:
          cpu: 5m
          memory: 50Mi
        limits:
          memory: 250Mi
      securityContext:
        runAsGroup: 0
        seccompProfile:
          type: RuntimeDefault
        allowPrivilegeEscalation: false
        capabilities:
          drop:
            - ALL
```
