#!/usr/bin/env bash
# No real backlight writes: exercise the production helper with a mock device.
set -euo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
script="$root/home/jwlee/quickshell/scripts/brightness-control.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export RESULT="$tmp/result"
printf '#!%s\ncase "$1" in max) echo "$MAX";; get) echo "$CURRENT";; set) echo "$2" > "$RESULT";; esac\n' "$(command -v bash)" > "$tmp/brightnessctl"
chmod +x "$tmp/brightnessctl"
export PATH="$tmp:$PATH"
check() {
  export MAX="$1" CURRENT="$2"
  local expected="$3" actual
  shift 3
  bash -euo pipefail "$script" "$@"
  read -r actual < "$RESULT"
  test "$actual" = "$expected"
}
check 1000 50 50 down
check 1000 1000 1000 up
check 937 47 47 set 0
check 937 500 937 set 101
check 1000 500 490 set 49
check 10 1 1 down
export MAX=1000 CURRENT=500
test "$(bash -euo pipefail "$script" get)" = 50
for value in bad -1 1.5 1000 ''; do
  if bash -euo pipefail "$script" set "$value"; then
    echo "Invalid brightness accepted: $value" >&2
    exit 1
  fi
done
echo 'PASS: brightness bounds, hardware rounding, readback and invalid input'
