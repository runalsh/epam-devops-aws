#!/usr/bin/env sh
set -eu

envsubst '${backapp}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

exec "$@"
