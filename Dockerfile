FROM alpine:3.21.2

ENV KEEPALIVED_INTERFACE=eth0
ENV KEEPALIVED_STATE=BACKUP
ENV KEEPALIVED_ROUTER_ID=21
ENV KEEPALIVED_PRIORITY=150
ENV KEEPALIVED_UNICAST_PEERS="192.168.0.11 - 192.168.0.12"
ENV KEEPALIVED_VIRTUAL_IPS=192.168.0.10
ENV KEEPALIVED_VIRTUAL_ROUTES="192.168.0.0/24 dev eth0 scope link src 192.168.0.10"
ENV KEEPALIVED_PASSWORD=d0ck3r
ENV KEEPALIVED_NOTIFY='notify "/usr/local/bin/keepalived-notify.sh"'

# enable_script_security makes keepalived drop privileges for notify scripts to
# the keepalived_script user; it refuses to start when that user is missing
RUN adduser -S -D -H -s /sbin/nologin keepalived_script; \
    apk add --no-cache \
      keepalived==2.3.1-r0 \
      envsubst; \
    rm -rf /var/cache/apk/*;

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY keepalived-notify.sh /usr/local/bin/keepalived-notify.sh
COPY keepalived.conf.tmpl /etc/keepalived/keepalived.conf.tmpl

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/sbin/keepalived","--dont-fork","--log-console", "-f","/etc/keepalived/keepalived.conf"]
