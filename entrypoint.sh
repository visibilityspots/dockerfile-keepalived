#!/bin/sh

# keepalived wants one unicast peer per line, while the environment variable
# carries them as a single " - " separated string
KEEPALIVED_UNICAST_PEERS=$(printf '%s' "${KEEPALIVED_UNICAST_PEERS}" | sed 's/ - /\n/g')
export KEEPALIVED_UNICAST_PEERS

# the health check is optional; without a command both blocks stay empty so an
# existing configuration renders exactly as it did before
if [ -n "${KEEPALIVED_CHECK_COMMAND}" ]; then
  KEEPALIVED_VRRP_SCRIPT=$(cat <<EOF
vrrp_script check_service {
  script "/usr/local/bin/keepalived-check.sh"
  interval ${KEEPALIVED_CHECK_INTERVAL}
  timeout ${KEEPALIVED_CHECK_TIMEOUT}
  fall ${KEEPALIVED_CHECK_FALL}
  rise ${KEEPALIVED_CHECK_RISE}
  # weight 0 means a failing check moves the instance to FAULT and releases the
  # virtual ip outright, instead of lowering the priority and hoping a peer
  # outbids it. With equal priorities and nopreempt that is the only
  # predictable outcome.
  weight 0
}
EOF
)
  KEEPALIVED_TRACK_SCRIPT=$(cat <<'EOF'
track_script {
    check_service
  }
EOF
)
else
  KEEPALIVED_VRRP_SCRIPT=""
  KEEPALIVED_TRACK_SCRIPT=""
fi
export KEEPALIVED_VRRP_SCRIPT KEEPALIVED_TRACK_SCRIPT

# VRRPv3 dropped authentication from the protocol: keepalived ignores the block
# and warns about it, so it is left out entirely rather than rendered and
# discarded. VRRPv3 is also the only version that accepts a fractional
# advert_int; v2 rounds it to whole seconds and refuses the config.
case "${KEEPALIVED_VERSION}" in
  3)
    KEEPALIVED_AUTH=""
    ;;
  *)
    KEEPALIVED_AUTH=$(cat <<EOF
authentication {
    auth_type PASS
    auth_pass ${KEEPALIVED_PASSWORD}
  }
EOF
)
    ;;
esac
export KEEPALIVED_AUTH

# without a virtual mac the virtual ip migrates between the real mac addresses
# of the participating hosts, which mac aware equipment reports as an ip
# conflict. use_vmac gives the address a stable 00:00:5e:00:01:<router_id> mac
# that moves along with it.
#
# vmac_xmit_base sends the vrrp adverts over the underlying interface rather
# than the vmac interface. That is required here: the vmac interface only
# carries the virtual ip, so unicast adverts sourced from it never reach peers
# that expect them from the host address.
case "${KEEPALIVED_USE_VMAC}" in
  true|TRUE|yes|1)
    KEEPALIVED_VMAC=$(cat <<'EOF'
use_vmac
  vmac_xmit_base
EOF
)
    ;;
  *)
    KEEPALIVED_VMAC=""
    ;;
esac
export KEEPALIVED_VMAC

# override environment variables into configuration file. The destination is
# overridable so a test can render somewhere harmless instead of over the
# configuration the running keepalived is using.
KEEPALIVED_CONF="${KEEPALIVED_CONF:-/etc/keepalived/keepalived.conf}"
envsubst < /etc/keepalived/keepalived.conf.tmpl > "${KEEPALIVED_CONF}"

# Run the standard container command.
exec "$@"
