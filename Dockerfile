FROM alpine

WORKDIR /home/cooltainer

ENV HOME=/home/cooltainer
ENV VIRTCTL_VERSION="v1.1.0"

RUN mkdir -p /home/cooltainer/.kube && mkdir -p /home/cooltainer/.mc
COPY functions ./functions
RUN chmod -R +x functions/*
RUN mv functions/* /usr/local/bin
RUN mkdir -p /.ssh
RUN chgrp -R 0 /.ssh && \
    chmod -R g+rwX /.ssh

# install go
COPY --from=golang:1.23-alpine /usr/local/go/ /usr/local/go/
 
ENV PATH="/usr/local/go/bin:${PATH}"

# virtctl
RUN wget https://github.com/kubevirt/kubevirt/releases/download/${VIRTCTL_VERSION}/virtctl-${VIRTCTL_VERSION}-linux-amd64

RUN chmod +x virtctl-${VIRTCTL_VERSION}-linux-amd64
RUN mv virtctl-${VIRTCTL_VERSION}-linux-amd64 /usr/local/bin/virtctl

# packages
RUN apk add --no-cache \
    curl \
    wget \
    figlet \
    jq \
    tar \
    bash \
    bash-completion \
    bash-doc \
    coreutils \
    ca-certificates \
    gcompat \
    traceroute \
    openssh \
    net-tools \
    netcat-openbsd \
    freeradius-utils \
    tzdata \
    vim \
    rclone \
    postgresql
# nats
RUN <<EOT
    go install -ldflags="-X main.version=v2.8.8" github.com/nats-io/nsc/v2@2.8.8
    go install github.com/nats-io/nats-top@latest
    go install github.com/nats-io/natscli/nats@latest
EOT

# kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

# mc
RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc --create-dirs -o mc
RUN chmod +x mc 
RUN mv ./mc /usr/local/bin

# oc
RUN curl https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz -o oc.tar
RUN tar -xf oc.tar

RUN chmod +x oc && mv oc /usr/local/bin
RUN chgrp -R 0 /usr/local/bin/oc && \
    chmod -R g+rwX /usr/local/bin/oc
# user
RUN addgroup -S cooltainer && adduser -S cooltainer -G cooltainer -u 1234
ENV HOME=/home/cooltainer

RUN mkdir -p /home/cooltainer/.ssh
RUN mkdir -p /home/cooltainer/.cache
RUN mkdir -p /home/cooltainer/go

RUN chgrp -R 0 /home/cooltainer && \
    chmod -R g=u /home/cooltainer

COPY profile.sh /etc/profile.d
RUN chmod +x /etc/profile.d/profile.sh

RUN rm README.md

USER 1234

# entrypoint
CMD ["sh", "-c", "tail -f /dev/null"]
