#!/usr/bin/env bash
# Safe routing tests: never call the real session/power commands.
set -euo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
script="$root/home/jwlee/quickshell/scripts/power-action.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export POWER_TEST_LOG="$tmp/actions"
for command in loginctl systemctl uwsm; do
  printf '#!/usr/bin/env bash\nprintf "%%s %%s\\n" "${0##*/}" "$*" >> "$POWER_TEST_LOG"\n' > "$tmp/$command"
  chmod +x "$tmp/$command"
done
export PATH="$tmp:$PATH"
for action in lock suspend logout reboot poweroff; do
  bash -euo pipefail "$script" "$action"
done
printf 'loginctl lock-session\nsystemctl suspend\nuwsm stop\nsystemctl reboot\nsystemctl poweroff\n' > "$tmp/expected"
diff -u "$tmp/expected" "$POWER_TEST_LOG"
if bash -euo pipefail "$script" invalid 2>/dev/null; then
  echo 'Invalid action was accepted' >&2
  exit 1
fi
diff -u "$tmp/expected" "$POWER_TEST_LOG"
echo 'PASS: five power routes and invalid action rejection'
