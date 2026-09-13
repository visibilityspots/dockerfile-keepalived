FROM alpine:3.24.1

ENV KEEPALIVED_INTERFACE=eth0
ENV KEEPALIVED_STATE=BACKUP
ENV KEEPALIVED_ROUTER_ID=21
ENV KEEPALIVED_PRIORITY=150

# how often the master advertises, in seconds; fractions are allowed. A backup
# declares the master gone after roughly three of these, so this is what decides
# the failover time when a host dies outright and never gets to say goodbye. A
# master that fails its health check or shuts down cleanly sends a priority 0
# advert instead and is taken over immediately, regardless of this value.
ENV KEEPALIVED_ADVERT_INT=1

# vrrp protocol version. 2 is the default and the only one that carries the
# authentication block; 3 drops authentication but is the only one that accepts
# a fractional KEEPALIVED_ADVERT_INT, so it is what sub second failover needs.
ENV KEEPALIVED_VERSION=2
ENV KEEPALIVED_UNICAST_PEERS="192.168.0.11 - 192.168.0.12"
ENV KEEPALIVED_VIRTUAL_IPS=192.168.0.10
ENV KEEPALIVED_VIRTUAL_ROUTES="192.168.0.0/24 dev eth0 scope link src 192.168.0.10"
ENV KEEPALIVED_PASSWORD=d0ck3r
ENV KEEPALIVED_NOTIFY='notify "/usr/local/bin/keepalived-notify.sh"'

# optional health check; empty means no vrrp_script/track_script is rendered at
# all, so existing configurations keep the behaviour they had before
ENV KEEPALIVED_CHECK_COMMAND=""
ENV KEEPALIVED_CHECK_INTERVAL=2
ENV KEEPALIVED_CHECK_TIMEOUT=2
ENV KEEPALIVED_CHECK_FALL=2
ENV KEEPALIVED_CHECK_RISE=2

# optional virtual mac, so the virtual ip keeps one mac address across a
# failover instead of migrating between the hosts' own mac addresses
ENV KEEPALIVED_USE_VMAC=false

ENV KEEPALIVED_CONF=/etc/keepalived/keepalived.conf

# enable_script_security makes keepalived drop privileges for notify scripts to
# the keepalived_script user; it refuses to start when that user is missing
RUN adduser -S -D -H -s /sbin/nologin keepalived_script; \
    apk add --no-cache \
      keepalived==2.3.4-r2 \
      envsubst; \
    rm -rf /var/cache/apk/*;

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY keepalived-notify.sh /usr/local/bin/keepalived-notify.sh
COPY keepalived-check.sh /usr/local/bin/keepalived-check.sh
COPY keepalived.conf.tmpl /etc/keepalived/keepalived.conf.tmpl

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/sbin/keepalived","--dont-fork","--log-console", "-f","/etc/keepalived/keepalived.conf"]
