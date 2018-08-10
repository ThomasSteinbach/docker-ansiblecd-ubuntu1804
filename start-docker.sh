#!/bin/sh

/lib/systemd/systemd

if [ -f "$1/requirements.yml" ]; then
  ansible-galaxy install -r "$1/requirements.yml"
fi

ansible-playbook "$1/site.yml"
