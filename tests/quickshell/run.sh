#!/usr/bin/env bash
# Offline tests only: no session, hardware or service changes.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
for suite in calendar battery sound; do
  node "$here/$suite.cjs"
done
bash "$here/brightness.sh"
bash "$here/power-action.sh"
