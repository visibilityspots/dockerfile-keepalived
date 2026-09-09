#!/bin/sh

# keepalived wants one unicast peer per line, while the environment variable
# carries them as a single " - " separated string
KEEPALIVED_UNICAST_PEERS=$(printf '%s' "${KEEPALIVED_UNICAST_PEERS}" | sed 's/ - /\n/g')
export KEEPALIVED_UNICAST_PEERS

# override environment variables into configuration file
envsubst < /etc/keepalived/keepalived.conf.tmpl > /etc/keepalived/keepalived.conf

# Run the standard container command.
exec "$@"
