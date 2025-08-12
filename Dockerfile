# renovate: datasource=golang-version depName=golang
ARG GOLANG_VERSION=1.24

FROM golang:${GOLANG_VERSION}-alpine AS go

# renovate: datasource=github-releases depName=nats-io/nsc versioning=loose
ARG NSC_VERSION=v2.11.0

# renovate: datasource=github-releases depName=nats-io/nats-top versioning=loose
ARG NATSTOP_VERSION=v0.6.3

# renovate: datasource=github-releases depName=nats-io/natscli versioning=loose
ARG NATSCLI_VERSION=v0.2.4

RUN go install -ldflags="-X main.version=${NSC_VERSION}" github.com/nats-io/nsc/v2@${NSC_VERSION} && \
    go install github.com/nats-io/nats-top@${NATSTOP_VERSION} && \
    go install github.com/nats-io/natscli/nats@${NATSCLI_VERSION}

FROM alpine:3.22.1

COPY --from=go /go/bin/nsc /usr/local/bin/nsc
COPY --from=go /go/bin/nats-top /usr/local/bin/nats-top
COPY --from=go /go/bin/nats /usr/local/bin/nats

# renovate: datasource=repology depName=homebrew/openshift-cli versioning=loose
ARG OC_VERSION=4.19.6

# renovate: datasource=github-tags depName=kubevirt/kubevirt versioning=loose
ARG VIRTCTL_VERSION=v1.6.0


# renovate: datasource=github-releases depName=minio/mc versioning=loose
ARG MC_VERSION=RELEASE.2025-05-21T01-59-54Z

# renovate: datasource=github-tags depName=kubernetes/kubectl versioning=loose
ARG KUBECTL_VERSION=v1.30.2

# renovate: datasource=repology depName=alpine_3_22/curl versioning=loose
ARG CURL_VERSION=8.14.1-r1

# renovate: datasource=repology depName=alpine_3_22/wget versioning=loose
ARG WGET_VERSION=1.25.0-r1

# renovate: datasource=repology depName=alpine_3_22/figlet versioning=loose
ARG FIGLET_VERSION=2.2.5-r3

# renovate: datasource=repology depName=alpine_3_22/jq versioning=loose
ARG JQ_VERSION=1.8.0-r0

# renovate: datasource=repology depName=alpine_3_22/tar versioning=loose
ARG TAR_VERSION=1.35-r3

# renovate: datasource=repology depName=alpine_3_22/bash versioning=loose
ARG BASH_VERSION=5.2.37-r0

# renovate: datasource=repology depName=alpine_3_22/coreutils versioning=loose
ARG COREUTILS_VERSION=9.7-r1

# renovate: datasource=repology depName=alpine_3_22/ca-certificates versioning=loose
ARG CA_CERTIFICATES_VERSION=20250619-r0

# renovate: datasource=repology depName=alpine_3_22/gcompat versioning=loose
ARG GCOMPAT_VERSION=1.1.0-r4

# renovate: datasource=repology depName=alpine_3_22/traceroute versioning=loose
ARG TRACEROUTE_VERSION=2.1.6-r0

# renovate: datasource=repology depName=alpine_3_22/openssh versioning=loose
ARG OPENSSH_VERSION=10.0_p1-r7

# renovate: datasource=repology depName=alpine_3_22/net-tools versioning=loose
ARG NETTOOLS_VERSION=2.10-r3

# renovate: datasource=repology depName=alpine_3_22/netcat-openbsd versioning=loose
ARG NETCAT_OPENBSD_VERSION=1.229.1-r0

# renovate: datasource=repology depName=alpine_3_22/freeradius-utils versioning=loose
ARG FREERADIUS_UTILS_VERSION=3.0.27-r1

# renovate: datasource=repology depName=alpine_3_22/tzdata versioning=loose
ARG TZDATA_VERSION=2025b-r0

# renovate: datasource=repology depName=alpine_3_22/vim versioning=loose
ARG VIM_VERSION=9.1.1566-r0

# renovate: datasource=repology depName=alpine_3_22/rclone versioning=loose
ARG RCLONE_VERSION=1.69.3-r1

# renovate: datasource=repology depName=alpine_3_22/postgresql16 versioning=loose
ARG POSTGRESQL_VERSION=16.9-r0

WORKDIR /home/cooltainer

# rootless shenanigans
RUN addgroup -S cooltainer && adduser -S cooltainer -G cooltainer -u 1234
ENV HOME=/home/cooltainer
RUN mkdir -p /home/cooltainer/.kube && \
    mkdir -p /home/cooltainer/.mc && \
    mkdir -p /.ssh && \
    chgrp -R 0 /.ssh && \
    chmod -R g+rwX /.ssh && \
    mkdir -p /home/cooltainer/.ssh && \
    mkdir -p /home/cooltainer/.cache && \
    mkdir -p /home/cooltainer/go

RUN chgrp -R 0 /home/cooltainer && \
    chmod -R g=u /home/cooltainer

# custom functions
COPY functions/* /usr/local/bin/
RUN chmod -R +x /usr/local/bin/*

# install go
COPY --from=go /usr/local/go/ /usr/local/go/

ENV PATH="/usr/local/go/bin:${PATH}"

# install virtctl
RUN wget https://github.com/kubevirt/kubevirt/releases/download/${VIRTCTL_VERSION}/virtctl-${VIRTCTL_VERSION}-linux-amd64 && \
    chmod +x virtctl-${VIRTCTL_VERSION}-linux-amd64 && \
    mv virtctl-${VIRTCTL_VERSION}-linux-amd64 /usr/local/bin/virtctl

# install packages
RUN apk add --no-cache \
    curl=${CURL_VERSION} \
    wget=${WGET_VERSION} \
    figlet=${FIGLET_VERSION} \
    jq=${JQ_VERSION} \
    tar=${TAR_VERSION} \
    bash=${BASH_VERSION} \
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
    postgresql16=${POSTGRESQL_VERSION}

# install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin

# install mc
RUN curl https://dl.min.io/client/mc/release/linux-amd64/archive/mc.${MC_VERSION} --create-dirs -o mc && \
    chmod +x mc && \
    mv ./mc /usr/local/bin

# install oc
RUN curl https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OC_VERSION}/oc-mirror.tar.gz -o oc.tar.gz && \
    tar -xzvf oc.tar.gz && \
    mv oc-mirror oc && \
    chmod +x oc && mv oc /usr/local/bin && \
    chgrp -R 0 /usr/local/bin/oc && \
    chmod -R g+rwX /usr/local/bin/oc && \
    rm oc.tar.gz

# profile
COPY profile.sh /etc/profile.d
RUN chmod +x /etc/profile.d/profile.sh

# entrypoint
USER 1234
CMD ["sh", "-c", "tail -f /dev/null"]
