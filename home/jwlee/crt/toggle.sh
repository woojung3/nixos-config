# Runtime-only state is isolated by compositor instance, not persisted at login.
: "${XDG_RUNTIME_DIR:?No session runtime directory}"
: "${HYPRLAND_INSTANCE_SIGNATURE:?Not running in a Hyprland session}"
: "${BLOOM_CRT_SHADER:?No CRT shader configured}"
[[ "$HYPRLAND_INSTANCE_SIGNATURE" =~ ^[a-zA-Z0-9_.-]+$ ]] || exit 1

umask 077
state_dir="$XDG_RUNTIME_DIR/bloom-crt/$HYPRLAND_INSTANCE_SIGNATURE"
mkdir -p "$state_dir"
exec 9> "$state_dir/lock"
flock 9
state="$state_dir/previous.json"
current_shader=$(hyprctl -j getoption decoration:screen_shader | jq -er '.str | strings')
current_cursor=$(hyprctl -j getoption cursor:no_hardware_cursors | jq -er '.int | numbers')

# Apply both settings as a pair. If either IPC operation fails, keep the
# original state rather than leaving a partially enabled mode behind.
apply() {
  local shader="$1" cursor="$2"
  if ! hyprctl keyword cursor:no_hardware_cursors "$cursor" >/dev/null; then
    return 1
  fi
  if ! hyprctl keyword decoration:screen_shader "${shader:-[[EMPTY]]}" >/dev/null; then
    hyprctl keyword decoration:screen_shader "${current_shader:-[[EMPTY]]}" >/dev/null || true
    hyprctl keyword cursor:no_hardware_cursors "$current_cursor" >/dev/null || true
    return 1
  fi
}

if [[ "$current_shader" == "$BLOOM_CRT_SHADER" ]]; then
  # A missing snapshot must not make it impossible to turn the effect off.
  previous_shader='[[EMPTY]]'
  previous_cursor="$current_cursor"
  if [[ -f "$state" ]] && jq -e '
    (.shader | type == "string") and
    (.cursor | type == "number") and (.cursor >= 0 and .cursor <= 2)
  ' "$state" >/dev/null; then
    previous_shader=$(jq -r '.shader' "$state")
    previous_cursor=$(jq -r '.cursor' "$state")
  fi
  apply "$previous_shader" "$previous_cursor"
  rm -f "$state"
else
  # Disabling must remain possible if the shader was removed or its symlink
  # broke while active. Only activation needs to read the shader file.
  [[ -r "$BLOOM_CRT_SHADER" ]] || { echo 'CRT shader is not readable' >&2; exit 1; }
  snapshot=$(mktemp "$state_dir/snapshot.XXXXXX")
  trap 'rm -f "$snapshot"' EXIT
  jq -n --arg shader "$current_shader" --argjson cursor "$current_cursor" \
    '{shader: $shader, cursor: $cursor}' > "$snapshot"
  mv "$snapshot" "$state"
  # Composite the cursor through the same transform as the rest of the image.
  if ! apply "$BLOOM_CRT_SHADER" 1; then
    rm -f "$state"
    exit 1
  fi
fi
