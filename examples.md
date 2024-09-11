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
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: httpd
      image: 'ghcr.io/nkzk/cooltainer'
      ports:
        - containerPort: 8080
      securityContext:
        allowPrivilegeEscalation: false
        runAsUser: 1234
        capabilities:
          drop:
            - ALL
```
