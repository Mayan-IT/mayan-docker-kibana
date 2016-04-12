#!/bin/sh
set -e

echo "Using elastic at: ${ELASTICSEARCH_URL}"
set -- su-exec kibana tini -s -- kibana

exec "$@"
