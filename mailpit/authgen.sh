#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "${DIR}" || exit 1

OUTFILE=auth
USERNAME=smtp
PASSWORD=pass123

if [[ -f "$OUTFILE" ]]; then
  mv "$OUTFILE" "$OUTFILE.$(date +%s)".bak
fi
htpasswd -bB -c "$OUTFILE" "$USERNAME" "$PASSWORD"