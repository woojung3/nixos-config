# Runtime-only state is isolated by compositor instance, not persisted at login.
: "${XDG_RUNTIME_DIR:?No session runtime directory}"
: "${HYPRLAND_INSTANCE_SIGNATURE:?Not running in a Hyprland session}"
: "${BLOOM_CRT_SHADER:?No CRT shader configured}"
: "${BLOOM_CRT_FULL_REDRAW:=1}"
[[ "$HYPRLAND_INSTANCE_SIGNATURE" =~ ^[a-zA-Z0-9_.-]+$ ]] || exit 1

umask 077
state_dir="$XDG_RUNTIME_DIR/bloom-crt/$HYPRLAND_INSTANCE_SIGNATURE"
mkdir -p "$state_dir"
exec 9> "$state_dir/lock"
flock 9
state="$state_dir/previous.json"
current_shader=$(hyprctl -j getoption decoration:screen_shader | jq -er '.str | strings')
current_cursor=$(hyprctl -j getoption cursor:no_hardware_cursors | jq -er '.int | numbers')

current_damage=$(hyprctl -j getoption debug:damage_tracking | jq -er '.int | numbers')

# Treat shader, cursor and redraw policy as one transaction. Mode 1 redraws a
# changed monitor in full, but unlike mode 0 does not force unchanged frames.
apply() {
  local shader="$1" cursor="$2" damage="$3"
  if hyprctl keyword debug:damage_tracking "$damage" >/dev/null &&
     hyprctl keyword cursor:no_hardware_cursors "$cursor" >/dev/null &&
     hyprctl keyword decoration:screen_shader "${shader:-[[EMPTY]]}" >/dev/null; then
    return 0
  fi
  hyprctl keyword decoration:screen_shader "${current_shader:-[[EMPTY]]}" >/dev/null || true
  hyprctl keyword cursor:no_hardware_cursors "$current_cursor" >/dev/null || true
  hyprctl keyword debug:damage_tracking "$current_damage" >/dev/null || true
  return 1
}

if [[ "$current_shader" == "$BLOOM_CRT_SHADER" ]]; then
  # A missing snapshot must not make it impossible to turn the effect off.
  previous_shader='[[EMPTY]]'
  previous_cursor="$current_cursor"
  previous_damage="$current_damage"
  if [[ -f "$state" ]] && jq -e '
    (.shader | type == "string") and
    (.cursor | type == "number") and (.cursor >= 0 and .cursor <= 2)
  ' "$state" >/dev/null; then
    previous_shader=$(jq -r '.shader' "$state")
    previous_cursor=$(jq -r '.cursor' "$state")
    # Snapshots without a redraw policy are also valid; do not invent a prior
    # value when disabling an effect enabled by a different toggle version.
    if saved_damage=$(jq -er '.damage | select(. == 0 or . == 1 or . == 2)' "$state"); then
      previous_damage="$saved_damage"
    fi
  fi
  apply "$previous_shader" "$previous_cursor" "$previous_damage"
  rm -f "$state"
else
  # Disabling must remain possible if the shader was removed or its symlink
  # broke while active. Only activation needs to read the shader file.
  [[ -r "$BLOOM_CRT_SHADER" ]] || { echo 'CRT shader is not readable' >&2; exit 1; }
  [[ "$BLOOM_CRT_FULL_REDRAW" =~ ^[01]$ ]] || { echo 'Invalid CRT redraw policy' >&2; exit 1; }
  desired_damage="$current_damage"
  if [[ "$BLOOM_CRT_FULL_REDRAW" == 1 ]]; then desired_damage=1; fi
  snapshot=$(mktemp "$state_dir/snapshot.XXXXXX")
  trap 'rm -f "$snapshot"' EXIT
  jq -n --arg shader "$current_shader" --argjson cursor "$current_cursor" \
    --argjson damage "$current_damage" \
    '{shader: $shader, cursor: $cursor, damage: $damage}' > "$snapshot"
  mv "$snapshot" "$state"
  # Composite the cursor through the same transform as the rest of the image.
  if ! apply "$BLOOM_CRT_SHADER" 1 "$desired_damage"; then
    rm -f "$state"
    exit 1
  fi
fi
