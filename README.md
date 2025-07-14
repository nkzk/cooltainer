# Cooltainer

Container with useful tools for developers and platform-engineers.

Made to run without issues in rootless environments like OpenShift.

Contains the following tools:
- oc (openshift-cli)
- kubectl
- virtctl
- nats cli/nsc/top
- mc (minio-client)
- curl
- wget
- jq
- tar
- bash
- traceroute
- openssh
- netcat
- freeradius
- vim
- rclone
- postgresl16

For an up to date list of available tools, check [./Dockerfile](https://github.com/nkzk/cooltainer/blob/main/Dockerfile).

## Usage

### docker 

```sh
docker run -it ghcr.io/nkzk/cooltainer -- /bin/sh
```

### kubectl
```sh
namespace=default
kubectl -n $namespace run -it cooltainer --image=ghcr.io/nkzk/cooltainer:latest /bin/sh
```

### Manifests

#### Kubernetes: Bare minimum
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: debug
  labels:
    app: debug
  namespace: default
spec:
  containers:
    - name: debug
      image: 'ghcr.io/nkzk/cooltainer:latest'
      resources:
        requests:
          cpu: 5m
          memory: 50Mi
        limits:
          memory: 250Mi
```

#### Kubernetes: run as group 0

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: debug
  labels:
    app: debug
  namespace: default
spec:
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
```

#### Openshift: with security context (drop all capabilities)

```yaml
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
        seccompProfile:
          type: RuntimeDefault
        allowPrivilegeEscalation: false
        capabilities:
          drop:
            - ALL
```

#### .bashrc debugpod shortcut/alias

Add this to `~/.bashrc`

```sh
debugpod(){
      if [[ "$#" -eq 1 ]];
      then
        echo "Starting"
        kubectl run -i -t --rm --image=ghcr.io/nkzk/cooltainer:latest --restart=Never debug -n $1 -- /bin/sh
      else
        echo "Illegal number of arguments. Include namespace as argument"
      fi
    }
```

Source .bashrc: `. ~/.bashrc`

Start debugpod with `debugpod`