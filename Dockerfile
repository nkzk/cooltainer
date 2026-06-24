# renovate: datasource=golang-version depName=golang
ARG GOLANG_VERSION=1.26

FROM golang:${GOLANG_VERSION}-alpine AS go

# renovate: datasource=github-releases depName=nats-io/nsc versioning=loose
ARG NSC_VERSION=v2.12.2

# renovate: datasource=github-releases depName=nats-io/nats-top versioning=loose
ARG NATSTOP_VERSION=v0.6.4

# renovate: datasource=github-releases depName=nats-io/natscli versioning=loose
ARG NATSCLI_VERSION=v0.3.2

RUN go install -ldflags="-X main.version=${NSC_VERSION}" github.com/nats-io/nsc/v2@${NSC_VERSION} && \
    go install github.com/nats-io/nats-top@${NATSTOP_VERSION} && \
    go install github.com/nats-io/natscli/nats@${NATSCLI_VERSION}

FROM alpine:3.23.3

COPY --from=go /go/bin/nsc /usr/local/bin/nsc
COPY --from=go /go/bin/nats-top /usr/local/bin/nats-top
COPY --from=go /go/bin/nats /usr/local/bin/nats

# renovate: datasource=repology depName=homebrew/openshift-cli versioning=loose
ARG OC_VERSION=4.20.1

# renovate: datasource=github-tags depName=kubevirt/kubevirt versioning=loose
ARG VIRTCTL_VERSION=v1.8.3


# renovate: datasource=github-releases depName=minio/mc versioning=loose
ARG MC_VERSION=RELEASE.2025-05-21T01-59-54Z

# renovate: datasource=github-tags depName=kubernetes/kubectl versioning=loose
ARG KUBECTL_VERSION=v1.30.2

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
    bash \
    ca-certificates \
    coreutils \
    curl \
    figlet \
    freeradius-utils \
    gcompat \
    jq \
    net-tools \
    netcat-openbsd \
    openssh \
    postgresql16 \
    rclone \
    tar \
    traceroute \
    tzdata \
    vim \
    wget

# install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin

# install mc
RUN curl https://dl.min.io/client/mc/release/linux-amd64/archive/mc.${MC_VERSION} --create-dirs -o mc && \
    chmod +x mc && \
    mv ./mc /usr/local/bin

# profile
COPY profile.sh /etc/profile.d
RUN chmod +x /etc/profile.d/profile.sh

# entrypoint
USER 1234
CMD ["sh", "-c", "tail -f /dev/null"]
