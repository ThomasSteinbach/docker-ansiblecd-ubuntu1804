FROM ubuntu:18.04
LABEL maintainer="Thomas Steinbach"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         python-software-properties \
         software-properties-common \
         rsyslog \
         systemd \
         systemd-cron \
         sudo \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean

RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

COPY initctl_faker.sh .

RUN chmod +x initctl_faker && \
    rm -fr /sbin/initctl && \
    ln -s /initctl_faker.sh /sbin/initctl

ENTRYPOINT ["/lib/systemd/systemd"]
