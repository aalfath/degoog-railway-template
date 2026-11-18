#!/bin/sh
# Railway wrapper for degoog. Sets the port and proxy handling, then hands over
# to the image's own entrypoint (which owns /app/data and drops to uid 1000).
set -e

# Listen on the port Railway routes the domain and health check to.
export DEGOOG_PORT="${PORT:-${DEGOOG_PORT:-4444}}"

# degoog always sits behind Railway's edge proxy. Trust its X-Forwarded-* headers
# so per-visitor rate limits, the settings-login lockout and the Secure cookie
# flag see the real client and https. Railway's edge replaces any client-sent
# X-Forwarded-For, so the first entry is the real visitor.
export DEGOOG_DISTRUST_PROXY="${DEGOOG_DISTRUST_PROXY:-0}"

export DEGOOG_DATA_DIR="${DEGOOG_DATA_DIR:-/app/data}"

if [ -z "${DEGOOG_SETTINGS_PASSWORDS:-}" ]; then
  echo "railway-start: DEGOOG_SETTINGS_PASSWORDS is empty; degoog will print a one-off settings password in this log." >&2
fi

exec /entrypoint.sh "$@"
