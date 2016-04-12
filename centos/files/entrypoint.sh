#!/bin/sh
set -e

echo "Using elastic at: ${ELASTICSEARCH_URL}"
set -- /usr/local/sbin/gosu kibana tini -s -- kibana

exec "$@"
