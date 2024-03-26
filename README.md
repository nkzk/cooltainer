# Cooltainer

Container with tools for common tasks or debugging:

- sh/bash shells
- curl
- wget
- kubectl
- oc
- mc

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
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop:
            - ALL
```