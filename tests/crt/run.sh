#!/usr/bin/env bash
# Mock IPC only; never applies a shader or changes the real compositor.
set -euo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
script="$root/home/jwlee/crt/toggle.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cp "$root/tests/crt/hyprctl-mock.sh" "$tmp/hyprctl"
chmod +x "$tmp/hyprctl"
export PATH="$tmp:$PATH" XDG_RUNTIME_DIR="$tmp/runtime"
export HYPRLAND_INSTANCE_SIGNATURE=test-session
export BLOOM_CRT_SHADER="$tmp/crt.frag" BLOOM_CRT_FULL_REDRAW=1
cp "$root/home/jwlee/crt/bloom-crt.frag" "$BLOOM_CRT_SHADER"
export MOCK_SETTINGS="$tmp/settings.json"
state="$XDG_RUNTIME_DIR/bloom-crt/$HYPRLAND_INSTANCE_SIGNATURE/previous.json"
settings() { jq -n --arg shader "$1" --argjson cursor "$2" --argjson damage "${3:-2}" '{shader:$shader,cursor:$cursor,damage:$damage}' > "$MOCK_SETTINGS"; }
run() { bash -euo pipefail "$script"; }
assert_settings() {
  jq -e --arg shader "$1" --argjson cursor "$2" --argjson damage "${3:-2}" '.shader == $shader and .cursor == $cursor and .damage == $damage' "$MOCK_SETTINGS" >/dev/null
}

settings '[[EMPTY]]' 2
run
assert_settings "$BLOOM_CRT_SHADER" 1 1
test -f "$state"
run
assert_settings '[[EMPTY]]' 2
test ! -f "$state"

# Hyprland also represents a configured-but-disabled shader as an empty string.
settings '' 2
run; run
assert_settings '[[EMPTY]]' 2

settings /custom/shader.frag 0
run; run
assert_settings /custom/shader.frag 0

# File removal while enabled must never strand the user in CRT mode.
run
rm "$BLOOM_CRT_SHADER"
run
assert_settings /custom/shader.frag 0
test ! -f "$state"
if run 2>/dev/null; then echo 'Enabled an unreadable shader' >&2; exit 1; fi
assert_settings /custom/shader.frag 0
test ! -f "$state"
cp "$root/home/jwlee/crt/bloom-crt.frag" "$BLOOM_CRT_SHADER"

# Reloading Hyprland can reset settings without removing the runtime snapshot.
run
settings /reloaded/shader.frag 2
run; run
assert_settings /reloaded/shader.frag 2

# Losing the snapshot must still allow disabling the shader.
run
rm "$state"
run
assert_settings '[[EMPTY]]' 1 1

settings '[[EMPTY]]' 2
if FAIL_SHADER=1 run; then echo 'Shader failure was ignored' >&2; exit 1; fi
assert_settings '[[EMPTY]]' 2
test ! -f "$state"
if FAIL_CURSOR=1 run; then echo 'Cursor failure was ignored' >&2; exit 1; fi
assert_settings '[[EMPTY]]' 2
test ! -f "$state"

if FAIL_DAMAGE_VALUE=1 run; then echo 'Redraw failure was ignored' >&2; exit 1; fi
assert_settings '[[EMPTY]]' 2
test ! -f "$state"

# A failed disable keeps the original snapshot for retry.
run
if FAIL_DAMAGE_VALUE=2 run; then echo 'Restore failure was ignored' >&2; exit 1; fi
assert_settings "$BLOOM_CRT_SHADER" 1 1
test -f "$state"
run
assert_settings '[[EMPTY]]' 2

for damage in 0 1 2; do
  settings /custom/shader.frag 0 "$damage"
  run
  assert_settings "$BLOOM_CRT_SHADER" 1 1
  run
  assert_settings /custom/shader.frag 0 "$damage"
  BLOOM_CRT_FULL_REDRAW=0 run
  assert_settings "$BLOOM_CRT_SHADER" 1 "$damage"
  run
  assert_settings /custom/shader.frag 0 "$damage"
done

# A snapshot without a damage field still restores its known shader/cursor.
settings "$BLOOM_CRT_SHADER" 1 2
mkdir -p "$(dirname "$state")"
printf '{"shader":"/legacy.frag","cursor":0}\n' > "$state"
run
assert_settings /legacy.frag 0 2
settings '[[EMPTY]]' 2
if BLOOM_CRT_FULL_REDRAW=invalid run 2>/dev/null; then exit 1; fi
assert_settings '[[EMPTY]]' 2
test ! -f "$state"

pids=()
for _ in {1..10}; do run & pids+=("$!"); done
for pid in "${pids[@]}"; do wait "$pid"; done
assert_settings '[[EMPTY]]' 2

export HYPRLAND_INSTANCE_SIGNATURE=another-session
run; run
assert_settings '[[EMPTY]]' 2
if HYPRLAND_INSTANCE_SIGNATURE='' run 2>/dev/null; then exit 1; fi
assert_settings '[[EMPTY]]' 2

echo 'PASS: CRT toggle, shader/cursor/redraw restoration, lightweight mode, reload, recovery, IPC rollback, concurrent clicks and session isolation'
