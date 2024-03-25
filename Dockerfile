FROM alpine


WORKDIR /home/cooltainer

ENV HOME=/home/cooltainer

RUN mkdir /home/cooltainer && chgrp -R 0 /home/cooltainer && \
    chmod -R g+rwX /home/cooltainer

# packages
RUN apk add --no-cache \
    curl \
    wget \
    tar \
    bash \
    bash-completion \
    bash-doc \
    coreutils 

# kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

# mc
RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc --create-dirs -o mc
RUN chmod +x mc 
RUN mv ./mc /usr/local/bin

# oc
COPY oc.tar .
RUN tar -xf oc.tar && mv oc /usr/local/bin
RUN rm oc.tar

# user
RUN addgroup -S cooltainer && adduser -S cooltainer -G cooltainer
ENV HOME=/home/cooltainer
USER cooltainer

# entrypoint
ENTRYPOINT ["/bin/sh"]
#CMD ["tail", "-f", "/dev/null"]

