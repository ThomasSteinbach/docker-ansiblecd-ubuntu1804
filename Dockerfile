FROM ubuntu:18.04
MAINTAINER Thomas Steinbach
# with credits upstream: https://hub.docker.com/r/geerlingguy/docker-ubuntu1804-ansible/
# with credits upstream: https://github.com/naftulikay/docker-xenial-vm.git
# with credits to https://developers.redhat.com/blog/2014/05/05/running-systemd-within-docker-container/

ENV container=docker

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         python3-pip \
         python3-software-properties \
         software-properties-common \
         dbus \
         rsyslog \
         systemd \
         systemd-cron \
         sudo \
         docker.io \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean

# Ansible
RUN pip install ansible==2.6.2
RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# disable kernel logging
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

RUN \
    rm -f /usr/lib/systemd/system/sysinit.target.wants/systemd-firstboot.service; \
    rm -f /etc/systemd/system/*.wants/*; \
    rm -f /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup.service; \
    rm -f /lib/systemd/system/multi-user.target.wants/*; \
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN ln -s /usr/bin/python3 /usr/bin/python

COPY initctl_faker.sh .
RUN chmod +x initctl_faker.sh && \
    rm -fr /sbin/initctl && \
    ln -s /initctl_faker.sh /sbin/initctl

# custom utility for awaiting systemd "boot" in the container
COPY bin/systemd-await-target /usr/bin/systemd-await-target
COPY bin/wait-for-boot /usr/bin/wait-for-boot

VOLUME ["/sys/fs/cgroup"]
ENTRYPOINT ["/lib/systemd/systemd"]
