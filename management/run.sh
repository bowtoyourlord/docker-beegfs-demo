#!/bin/bash
#
# Wrapper around beegfs-mgmtd to start the service _and_ keep an eye
# on the log. beegfs-mgmtd is able to run non-daemonized, but it
# doesn't report anything on stdout/stderr.

# Comment connAuthFile path if USE_CONN_AUTH isn't set
if [ "$USE_CONN_AUTH" != "true" ]; then
    sed -i 's/^connAuthFile/#connAuthFile/' /etc/beegfs/beegfs-mgmtd.conf
fi

: ${BEEGFS_LOGLEVEL:="3"}

/opt/beegfs/sbin/beegfs-mgmtd \
    cfgFile=/etc/beegfs/beegfs-mgmtd.conf \
    logLevel=${BEEGFS_LOGLEVEL}

tail -f /var/log/beegfs-mgmtd.log
