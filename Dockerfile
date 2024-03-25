FROM alpine


WORKDIR /home/cooltainer

ENV HOME=/home/cooltainer

RUN mkdir -p /home/cooltainer/.kube && mkdir -p /home/cooltainer/.mc
RUN chgrp -R 0 /home/cooltainer && \
    chmod -R g+rwX /home/cooltainer
COPY functions ./functions
RUN chmod -R +x functions/*
RUN mv functions/* /usr/local/bin

# packages
RUN apk add --no-cache \
    curl \
    wget \
    tar \
    bash \
    bash-completion \
    bash-doc \
    coreutils \
    ca-certificates

# kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

# mc
RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc --create-dirs -o mc
RUN chmod +x mc 
RUN mv ./mc /usr/local/bin

# oc
COPY oc-4.15.3-linux.tar.gz .
RUN tar -xf oc-4.15.3-linux.tar.gz && mv oc /usr/local/bin

# user
RUN addgroup -S cooltainer && adduser -S cooltainer -G cooltainer
ENV HOME=/home/cooltainer

USER cooltainer

# entrypoint
CMD ["sh", "-c", "tail -f /dev/null"]
