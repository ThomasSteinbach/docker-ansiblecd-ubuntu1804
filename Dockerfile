FROM thomass/ansibleci-base:latest as ansibleci-base

FROM ubuntu:18.04
LABEL maintainer="Thomas Steinbach"

# with credits upstream: https://hub.docker.com/r/geerlingguy/docker-ubuntu1804-ansible/
# with credits upstream: https://github.com/naftulikay/docker-xenial-vm.git
# with credits to https://developers.redhat.com/blog/2014/05/05/running-systemd-within-docker-container/

ENV container=docker

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
         python3-pip \
         python3-software-properties \
         python3-setuptools \
         software-properties-common \
         dbus \
         rsyslog \
         systemd \
         systemd-cron \
         sudo \
         docker.io \
         ruby \
         ruby-dev \
         build-essential \
         libssl-dev \
         libffi-dev \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Ansible
RUN pip3 install ansible==2.6.2
RUN mkdir -p /etc/ansible
RUN printf '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

# Inspec
RUN gem install docker-api -v  1.34.2
RUN gem install inspec -v  2.2.61

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

COPY scripts/initctl_faker.sh .
RUN chmod +x initctl_faker.sh && \
    rm -fr /sbin/initctl && \
    ln -s /initctl_faker.sh /sbin/initctl

# custom utility for awaiting systemd "boot" in the container
COPY bin/systemd-await-target /usr/bin/systemd-await-target
COPY bin/wait-for-boot /usr/bin/wait-for-boot

VOLUME ["/sys/fs/cgroup"]

COPY scripts/start-docker.sh /usr/local/bin/start-docker.sh
CMD ["/usr/local/bin/start-docker.sh"]

COPY --from=ansibleci-base /ansibleci-base /ansibleci-base
RUN ln -s /ansibleci-base/scripts/run-tests.sh /usr/local/bin/run-tests && \
    ln -s /ansibleci-base/ansible-plugins/human_log.py /usr/local/lib/python3.6/dist-packages/ansible/plugins/callback/human_log.py
