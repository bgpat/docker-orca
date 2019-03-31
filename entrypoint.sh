#!/bin/sh

DBADDR=${DBHOST}${DBPORT:+:$DBPORT}

cat <<EOF > /etc/jma-receipt/dbgroup.inc
db_group {
 type "PostgreSQL";
 port "${DBADDR}";
 name "${DBNAME}";
 user "${DBUSER}";
 password "${DBPASS}";
 redirect "log";
};
db_group "log" {
 priority 100;
 type "PostgreSQL";
 port "sub-jma-receipt";
 name "orca";
 file "/var/lib/jma-receipt/dbredirector/orca.log";
 redirect_port "localhost";
};
EOF

/start.sh
