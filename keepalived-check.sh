#!/bin/sh

# wrapper around the health check configured in KEEPALIVED_CHECK_COMMAND
#
# keepalived runs track scripts as the unprivileged keepalived_script user
# because of enable_script_security, and it refuses to run a script that lives
# on a path writable by anyone but root. Keeping the executable inside the image
# and taking the actual command from the environment satisfies both: the file is
# root owned, while the command itself stays configurable at runtime.
#
# The exit status is what keepalived acts on: non zero for `fall` consecutive
# runs puts the vrrp instance in FAULT state and hands the virtual ip to a peer.

exec sh -c "${KEEPALIVED_CHECK_COMMAND}"
