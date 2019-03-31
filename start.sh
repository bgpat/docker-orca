#!/bin/bash

ORCAETC=/etc/jma-receipt
if [ -f "$ORCAETC"/jma-receipt.env ]
then
    . "$ORCAETC"/jma-receipt.env
fi

ORCAVAR=/var/run/jma-receipt
mkdir -p ${ORCAVAR}
chown "$ORCAUSER":"$ORCAGROUP" "$ORCAVAR"
chmod 755 "$ORCAVAR"

ORCATMPDIR=/tmp/jma-receipt

GLAUTH="$PANDALIB"/sbin/glauth
GLSERVER="$PANDALIB"/sbin/glserver
MONITOR="$PANDALIB"/sbin/monitor
PASSWDFILE="$ORCAETC"/passwd

CLAIM_SERVERDIR="$ORCALIBDIR"/scripts/claim/rb

GLSERVER_GLAUTH_URI=''
GLSERVER_CACHE="$ORCATMPDIR"/glserver.cache

GLSERVER_OPT='-glserver -api'
GLSERVER_OPT="$GLSERVER_OPT -screen $PATCHSCREENDIR:$SCREENDIR"
GLSERVER_OPT="$GLSERVER_OPT -glcache $GLSERVER_CACHE"
if [ "$GLSERVER_SSL" = true ];
then
  CAfile=/etc/ssl/certs/gl-cacert.pem
  if [ ! -f $CAfile ]
  then
    if [ -f /etc/ssl/gl-cacert.pem ]
    then
      CAfile=/etc/ssl/gl-cacert.pem
    fi
  fi
  GLSERVER_GLAUTH_URI='api://localhost/session/session_start'
  GLSERVER_OPT="$GLSERVER_OPT -glssl -glcafile $CAfile -glcert /etc/jma-receipt/glserver.p12"
else
  GLSERVER_GLAUTH_URI='api://localhost/session/session_start'
fi
GLSERVER_OPT="$GLSERVER_OPT -glauth $GLSERVER_GLAUTH_URI"
if [ "$NUMERICHOST" = true ];
then
    GLSERVER_OPT="$GLSERVER_OPT -numeric"
fi

plugin_check() {
  su - ${ORCAUSER} -c "${BINDIR}/plugin_check.sh"
}

master_convert_check() {
  su - ${ORCAUSER} -c "${BINDIR}/master_convert_check.sh"
}

test -f "$GLAUTH" || exit 0
test -f "$MONITOR" || exit 0

. /lib/lsb/init-functions

# set -e

plugin_check
master_convert_check

rm -fr "$ORCATMPDIR"
mkdir "$ORCATMPDIR"
chown "$ORCAUSER":"$ORCAGROUP" "$ORCATMPDIR"
      chmod 700 "$ORCATMPDIR"

# monitor
#
NAME=`basename "$MONITOR"`
COB_LIBRARY_PATH="$SITELIBDIR":"$PATCHLIBDIR":"$ORCALIBDIR":"$PANDALIB"
export COB_LIBRARY_PATH
MONITOR_OPT='-tempdirroot /tmp/jma-tempdir'
if [ "$RUN_REDIRECTOR" = true ]
then
  MONITOR_OPT="$MONITOR_OPT -redirector ON"
fi
start-stop-daemon --start --quiet -k 022 \
  --chuid "$ORCAUSER":"$ORCAGROUP" \
  --pidfile "$ORCAVAR"/"$NAME".pid --make-pidfile \
  --exec "$MONITOR" -- \
  -dir "$LDDIRECTORY" -restart -interval 1 -wfcwait 5 -retry 3 \
  $MONITOR_OPT \
  $GLSERVER_OPT
