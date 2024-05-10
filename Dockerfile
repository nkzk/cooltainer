FROM alpine


WORKDIR /home/cooltainer

ENV HOME=/home/cooltainer
ENV VIRTCTL_VERSION="v1.1.0"

RUN mkdir -p /home/cooltainer/.kube && mkdir -p /home/cooltainer/.mc
RUN chgrp -R 0 /home/cooltainer && \
    chmod -R g+rwX /home/cooltainer
COPY functions ./functions
RUN chmod -R +x functions/*
RUN mv functions/* /usr/local/bin
RUN mkdir -p /.ssh
RUN chgrp -R 0 /.ssh && \
    chmod -R g+rwX /.ssh
# virtctl
RUN wget https://github.com/kubevirt/kubevirt/releases/download/${VIRTCTL_VERSION}/virtctl-${VIRTCTL_VERSION}-linux-amd64

RUN chmod +x virtctl-${VIRTCTL_VERSION}-linux-amd64
RUN mv virtctl-${VIRTCTL_VERSION}-linux-amd64 /usr/local/bin/virtctl

# packages
RUN apk add --no-cache \
    curl \
    wget \
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
    freeradius-utils
# kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

# mc
RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc --create-dirs -o mc
RUN chmod +x mc 
RUN mv ./mc /usr/local/bin

# oc
ADD oc.tar .
# RUN tar -xf oc.tar
RUN chmod +x oc && mv oc /usr/local/bin
RUN chgrp -R 0 /usr/local/bin/oc && \
    chmod -R g+rwX /usr/local/bin/oc
# user
RUN addgroup -S cooltainer && adduser -S cooltainer -G cooltainer -u 1234
ENV HOME=/home/cooltainer

RUN chgrp -R 0 /home/cooltainer && \
    chmod -R g=u /home/cooltainer


RUN mkdir -p /home/cooltainer/.ssh
RUN chgrp -R 0 /home/cooltainer/.ssh && \
    chmod -R g=u /home/cooltainer/.ssh

USER 1234

# entrypoint
CMD ["sh", "-c", "tail -f /dev/null"]
