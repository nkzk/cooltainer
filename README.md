# Cooltainer

Container with tools for common tasks or debugging.


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
  creationTimestamp: null
  labels:
    run: cooltainer
  name: cooltainer
  namespace: default
spec:
  containers:
  - image: ghcr.io/nkzk/cooltainer:latest
    name: cooltainer
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```