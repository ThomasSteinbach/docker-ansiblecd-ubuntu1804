FROM ubuntu:18.04
LABEL maintainer="Thomas Steinbach"

RUN apt-get update \
    && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
         python3 \
         sudo \
         ssh \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN mkdir /run/sshd && \
    chmod 0755 /run/sshd

RUN useradd --home-dir /gitlab --create-home --groups sudo --shell /bin/bash gitlab
WORKDIR /gitlab
# https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo "gitlab:gitlab" | chpasswd

EXPOSE 22/tcp
HEALTHCHECK --interval=5s --timeout=3s \
  CMD < /dev/tcp/127.0.0.1/22

CMD ["/usr/sbin/sshd", "-D", "-e"]
