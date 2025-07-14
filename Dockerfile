FROM alpine:3.22.0

# renovate: datasource=golang-version depName=golang
ARG GOLANG_VERSION=1.24

# renovate: datasource=github-releases packageName=kubevirt/kubevirt
ARG VIRTCTL_VERSION=v1.5.2

# renovate: datasource=github-releases packageName=nats-io/nsc
ARG NSC_VERSION=v2.8.8

# renovate: datasource=github-releases packageName=minio/mc
ARG MC_VERSION=RELEASE.2025-05-21T01-59-54Z

# renovate: datasource=github-releases packageName=kubernetes/kubernetes
ARG KUBECTL_VERSION=v1.30.2

ARG OC_VERSION=latest

# renovate: datasource=repology depName=alpine_3_22/curl versioning=loose
ARG CURL_VERSION=7.88.1-r0

# renovate: datasource=repology depName=alpine_3_22/wget versioning=loose
ARG WGET_VERSION=1.21.4-r0

# renovate: datasource=repology depName=alpine_3_22/figlet versioning=loose
ARG FIGLET_VERSION=2.2.5_alpha-r2

# renovate: datasource=repology depName=alpine_3_22/jq versioning=loose
ARG JQ_VERSION=1.6-r0

# renovate: datasource=repology depName=alpine_3_22/tar versioning=loose
ARG TAR_VERSION=1.34-r1

# renovate: datasource=repology depName=alpine_3_22/bash versioning=loose
ARG BASH_VERSION=5.2.15-r0

# renovate: datasource=repology depName=alpine_3_22/bash_completion versioning=loose
ARG BASH_COMPLETION_VERSION=2.12-r0

# renovate: datasource=repology depName=alpine_3_22/bash_doc versioning=loose
ARG BASH_DOC_VERSION=5.2.15-r0

# renovate: datasource=repology depName=alpine_3_22/coreutils versioning=loose
ARG COREUTILS_VERSION=9.2.0-r0

# renovate: datasource=repology depName=alpine_3_22/ca_certificates versioning=loose
ARG CA_CERTIFICATES_VERSION=20230506-r0

# renovate: datasource=repology depName=alpine_3_22/gcompat versioning=loose
ARG GCOMPAT_VERSION=1.4.0-r3

# renovate: datasource=repology depName=alpine_3_22/traceroute versioning=loose
ARG TRACEROUTE_VERSION=2.1.0-r3

# renovate: datasource=repology depName=alpine_3_22/openssh versioning=loose
ARG OPENSSH_VERSION=9.4_p1-r0

# renovate: datasource=repology depName=alpine_3_22/nettools versioning=loose
ARG NETTOOLS_VERSION=2.11-r2

# renovate: datasource=repology depName=alpine_3_22/netcat_openbsd versioning=loose
ARG NETCAT_OPENBSD_VERSION=1.217-r2

# renovate: datasource=repology depName=alpine_3_22/freeradius_utils versioning=loose
ARG FREERADIUS_UTILS_VERSION=3.0.23-r1

# renovate: datasource=repology depName=alpine_3_22/tzdata versioning=loose
ARG TZDATA_VERSION=2023a-r0

# renovate: datasource=repology depName=alpine_3_22/vim versioning=loose
ARG VIM_VERSION=9.0.0219-r0

# renovate: datasource=repology depName=alpine_3_22/rclone versioning=loose
ARG RCLONE_VERSION=1.62.3-r0

# renovate: datasource=repology depName=alpine_3_22/postgresql versioning=loose
ARG POSTGRESQL_VERSION=15.3-r0


WORKDIR /home/cooltainer

# rootless shenanigans
RUN addgroup -S cooltainer && adduser -S cooltainer -G cooltainer -u 1234
ENV HOME=/home/cooltainer
RUN mkdir -p /home/cooltainer/.kube && mkdir -p /home/cooltainer/.mc
RUN mkdir -p /.ssh
RUN chgrp -R 0 /.ssh && \
    chmod -R g+rwX /.ssh


RUN mkdir -p /home/cooltainer/.ssh
RUN mkdir -p /home/cooltainer/.cache
RUN mkdir -p /home/cooltainer/go

RUN chgrp -R 0 /home/cooltainer && \
    chmod -R g=u /home/cooltainer

# custom functions
COPY functions/* /usr/local/bin/
RUN chmod -R +x /usr/local/bin/*

# install go
COPY --from=golang:${GOLANG_VERSION}-alpine /usr/local/go/ /usr/local/go/

ENV PATH="/usr/local/go/bin:${PATH}"

# install virtctl
RUN wget https://github.com/kubevirt/kubevirt/releases/download/${VIRTCTL_VERSION}/virtctl-${VIRTCTL_VERSION}-linux-amd64
RUN chmod +x virtctl-${VIRTCTL_VERSION}-linux-amd64
RUN mv virtctl-${VIRTCTL_VERSION}-linux-amd64 /usr/local/bin/virtctl

# install packages
RUN apk add --no-cache \
    curl=${CURL_VERSION} \
    wget=${WGET_VERSION} \
    figlet=${FIGLET_VERSION} \
    jq=${JQ_VERSION} \
    tar=${TAR_VERSION} \
    bash=${BASH_VERSION} \
    bash-completion=${BASH_COMPLETION_VERSION} \
    bash-doc=${BASH_DOC_VERSION} \
    coreutils=${COREUTILS_VERSION} \
    ca-certificates=${CA_CERTIFICATES_VERSION} \
    gcompat=${GCOMPAT_VERSION} \
    traceroute=${TRACEROUTE_VERSION} \
    openssh=${OPENSSH_VERSION} \
    net-tools=${NETTOOLS_VERSION} \
    netcat-openbsd=${NETCAT_OPENBSD_VERSION} \
    freeradius-utils=${FREERADIUS_UTILS_VERSION} \
    tzdata=${TZDATA_VERSION} \
    vim=${VIM_VERSION} \
    rclone=${RCLONE_VERSION} \
    postgresql=${POSTGRESQL_VERSION}

# install nats
RUN <<EOT
    go install -ldflags="-X main.version=v2.8.8" github.com/nats-io/nsc/v2@2.8.8
    go install github.com/nats-io/nats-top@latest
    go install github.com/nats-io/natscli/nats@latest
EOT

# install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

# install mc

RUN curl https://dl.min.io/client/mc/release/linux-amd64/archive/mc.${MC_VERSION} --create-dirs -o mc
RUN chmod +x mc 
RUN mv ./mc /usr/local/bin

# install oc
RUN curl https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz -o oc.tar
RUN tar -xf oc.tar

RUN chmod +x oc && mv oc /usr/local/bin
RUN chgrp -R 0 /usr/local/bin/oc && \
    chmod -R g+rwX /usr/local/bin/oc

# profile
COPY profile.sh /etc/profile.d
RUN chmod +x /etc/profile.d/profile.sh

RUN rm README.md

# entrypoint
USER 1234
CMD ["sh", "-c", "tail -f /dev/null"]
