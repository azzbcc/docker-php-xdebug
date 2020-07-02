#!/usr/bin/env sh

set -e

nginx
echo "nginx started"

exec "$@"
