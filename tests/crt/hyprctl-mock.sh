#!/usr/bin/env bash
set -euo pipefail
if [[ "$1" == -j && "$2" == getoption ]]; then
  case "$3" in
    decoration:screen_shader) jq '{str: .shader}' "$MOCK_SETTINGS" ;;
    cursor:no_hardware_cursors) jq '{int: .cursor}' "$MOCK_SETTINGS" ;;
    debug:damage_tracking) jq '{int: .damage}' "$MOCK_SETTINGS" ;;
    *) exit 1 ;;
  esac
elif [[ "$1" == keyword ]]; then
  case "$2" in
    decoration:screen_shader)
      if [[ "${FAIL_SHADER:-0}" == 1 && "$3" == "$BLOOM_CRT_SHADER" ]]; then exit 1; fi
      jq --arg value "$3" '.shader = $value' "$MOCK_SETTINGS" > "$MOCK_SETTINGS.next"
      ;;
    cursor:no_hardware_cursors)
      if [[ "${FAIL_CURSOR:-0}" == 1 && "$3" == 1 ]]; then exit 1; fi
      jq --argjson value "$3" '.cursor = $value' "$MOCK_SETTINGS" > "$MOCK_SETTINGS.next"
      ;;
    debug:damage_tracking)
      if [[ "${FAIL_DAMAGE_VALUE:-}" == "$3" ]]; then exit 1; fi
      jq --argjson value "$3" '.damage = $value' "$MOCK_SETTINGS" > "$MOCK_SETTINGS.next"
      ;;
    *) exit 1 ;;
  esac
  mv "$MOCK_SETTINGS.next" "$MOCK_SETTINGS"
else
  exit 1
fi
