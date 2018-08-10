#!/bin/sh

/lib/systemd/systemd

set -e

PLAYBOOK_FILE=${PLAYBOOK_FILE:-site.yml}

if [ -z "$REQUIREMENTS_FILE" ]; then
  ansible-galaxy install -r "${REQIREMENTS_FILE}"
fi

ansible-playbook "${PLAYBOOK_FILE}"

exec "$@"
