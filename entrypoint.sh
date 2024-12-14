#!/bin/sh

# override environment variables into configuration file
envsubst < /etc/keepalived/keepalived.conf.tmpl > /etc/keepalived/keepalived.conf

# Run the standard container command.
exec "$@"
